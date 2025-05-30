<script>
import { GlTruncate, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { escapeFileUrl } from '~/lib/utils/url_utility';
import FileIcon from '~/vue_shared/components/file_icon.vue';
import FileHeader from '~/vue_shared/components/file_row_header.vue';

export default {
  name: 'FileRow',
  components: {
    FileHeader,
    FileIcon,
    GlTruncate,
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    file: {
      type: Object,
      required: true,
    },
    fileUrl: {
      type: String,
      required: false,
      default: '',
    },
    level: {
      type: Number,
      required: true,
    },
    fileClasses: {
      type: String,
      required: false,
      default: '',
    },
    truncateMiddle: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    isTree() {
      return this.file.type === 'tree';
    },
    isBlob() {
      return this.file.type === 'blob';
    },
    fileClass() {
      return {
        'file-open': this.isBlob && this.file.opened,
        'is-active': this.isBlob && this.file.active,
        folder: this.isTree,
        'is-open': this.file.opened,
        'is-linked': this.file.linked,
      };
    },
    textForTitle() {
      // don't output a title if we don't have the expanded path
      return this.file?.tree?.length ? this.file.tree[0].parentPath : false;
    },
    fileRouterUrl() {
      return this.fileUrl || `/project${this.file.url}`;
    },
  },
  watch: {
    'file.active': function fileActiveWatch(active) {
      if (this.file.type === 'blob' && active) {
        this.scrollIntoView();
      }
    },
  },
  mounted() {
    if (this.hasPathAtCurrentRoute()) {
      this.scrollIntoView(true);
    }
  },
  methods: {
    toggleTreeOpen(path) {
      this.$emit('toggleTreeOpen', path);
    },
    clickFile() {
      // Manual Action if a tree is selected/opened
      if (this.isTree) this.$emit('clickTree', this.file.path);
      if (this.isTree && this.hasUrlAtCurrentRoute()) {
        this.toggleTreeOpen(this.file.path);
      }

      if (this.$router && !this.hasUrlAtCurrentRoute()) this.$router.push(this.fileRouterUrl);

      if (this.isBlob) this.$emit('clickFile', this.file);
    },
    scrollIntoView(isInit = false) {
      const block = isInit && this.isTree ? 'center' : 'nearest';

      this.$el.scrollIntoView({
        behavior: 'smooth',
        block,
      });
    },
    hasPathAtCurrentRoute() {
      if (!this.$router || !this.$router.currentRoute) {
        return false;
      }

      // - strip route up to "/-/" and ending "/"
      const routePath = this.$router.currentRoute.path
        .replace(/^.*?[/]-[/]/g, '')
        .replace(/[/]$/g, '');

      // - strip ending "/"
      const filePath = this.file.path.replace(/[/]$/g, '');

      return filePath === routePath;
    },
    hasUrlAtCurrentRoute() {
      if (!this.$router || !this.$router.currentRoute) return true;

      return escapeFileUrl(this.$router.currentRoute.path) === escapeFileUrl(this.fileRouterUrl);
    },
  },
};
</script>

<template>
  <file-header v-if="file.isHeader" :path="file.path" />
  <button
    v-else
    :class="fileClass"
    :title="textForTitle"
    :data-level="level"
    class="file-row"
    :aria-expanded="file.type === 'tree' ? file.opened.toString() : undefined"
    @click="clickFile"
  >
    <span
      ref="textOutput"
      class="file-row-name"
      :title="file.name"
      :data-qa-file-name="file.name"
      data-testid="file-row-name-container"
      :class="[fileClasses, { 'str-truncated': !truncateMiddle, 'gl-min-w-0': truncateMiddle }]"
    >
      <gl-icon
        v-if="file.linked"
        v-gl-tooltip="
          __('This file was linked in the page URL and will appear as the first one in the list')
        "
        name="link"
        :size="16"
      />
      <file-icon
        class="gl-mr-2"
        :class="{ 'gl-text-subtle': file.type === 'tree' }"
        :file-name="file.name"
        :loading="file.loading"
        :folder="isTree"
        :opened="file.opened"
        :size="16"
        :submodule="file.submodule"
      />
      <gl-truncate
        v-if="truncateMiddle"
        :text="file.name"
        position="middle"
        class="gl-items-center gl-pr-7"
      />
      <template v-else>{{ file.name }}</template>
    </span>
    <slot></slot>
  </button>
</template>

<style>
.file-row {
  display: flex;
  align-items: center;
  height: var(--file-row-height, 32px);
  padding: 4px 8px;
  margin-left: -8px;
  margin-right: -8px;
  border-radius: 3px;
  text-align: left;
  cursor: pointer;
  color: unset;
}

.file-row-name-container {
  display: flex;
  width: 100%;
  align-items: center;
  overflow: visible;
}

.file-row-name {
  display: flex;
  align-items: center;
  flex: 1;
  max-width: inherit;
  line-height: 1rem;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin-left: calc(var(--level) * var(--file-row-level-padding, 16px));
}
</style>
