# frozen_string_literal: true

module ResolvableNote
  extend ActiveSupport::Concern

  # Names of all subclasses of `Note` that can be resolvable.
  RESOLVABLE_TYPES = %w[DiffNote DiscussionNote].freeze

  included do
    belongs_to :resolved_by, class_name: "User"

    validates :resolved_by, presence: true, if: -> do
      resolved? &&
        # We can't guarantee that every ResolvableNote also includes the
        # Importing module, but if they do, we want to skip this validation.
        (respond_to?(:importing?) ? !importing? : true)
    end

    # Keep this scope in sync with `#potentially_resolvable?`
    scope :potentially_resolvable, -> { where(type: resolvable_types).where(noteable_type: Noteable.resolvable_types) }
    # Keep this scope in sync with `#resolvable?`
    scope :resolvable, -> { potentially_resolvable.user }

    scope :resolved, -> { resolvable.where.not(resolved_at: nil) }
    scope :unresolved, -> { resolvable.where(resolved_at: nil) }
  end

  class_methods do
    # This method must be kept in sync with `#resolve!`
    def resolve!(current_user)
      now = Time.current
      unresolved.update_all(updated_at: now, resolved_at: now, resolved_by_id: current_user.id)
    end

    # This method must be kept in sync with `#unresolve!`
    def unresolve!
      resolved.update_all(updated_at: Time.current, resolved_at: nil, resolved_by_id: nil)
    end

    # overridden on EE
    def resolvable_types
      RESOLVABLE_TYPES
    end
  end

  # Keep this method in sync with the `potentially_resolvable` scope
  def potentially_resolvable?
    self.class.resolvable_types.include?(self.class.name) && noteable&.supports_resolvable_notes?
  end

  # Keep this method in sync with the `resolvable` scope
  def resolvable?
    potentially_resolvable? && !system?
  end

  def resolved?
    return false unless resolvable?

    self.resolved_at.present?
  end

  def to_be_resolved?
    resolvable? && !resolved?
  end

  # If you update this method remember to also update `.resolve!`
  def resolve_without_save(current_user, resolved_by_push: false)
    return false unless resolvable?
    return false if resolved?

    now = Time.current
    self.updated_at = now
    self.resolved_at = now
    self.resolved_by = current_user
    self.resolved_by_push = resolved_by_push

    true
  end

  # If you update this method remember to also update `.unresolve!`
  def unresolve_without_save
    return false unless resolvable?
    return false unless resolved?

    self.updated_at = Time.current
    self.resolved_at = nil
    self.resolved_by = nil

    true
  end

  def resolve!(current_user, resolved_by_push: false)
    resolve_without_save(current_user, resolved_by_push: resolved_by_push) &&
      save!
  end

  def unresolve!
    unresolve_without_save && save!
  end
end

ResolvableNote::ClassMethods.prepend_mod_with('ResolvableNote::ClassMethods')
