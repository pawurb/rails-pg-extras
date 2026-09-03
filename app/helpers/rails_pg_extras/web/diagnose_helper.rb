# frozen_string_literal: true

module RailsPgExtras
  module Web
    module DiagnoseHelper
      COLLAPSE_AFTER = 5
      HOT_CHECKS = %i[new_page_updates low_hot_same_page].freeze
      # HOT checks report one "'table_name':" block per table.
      HOT_TABLE_BLOCK = /\A'[^\n']+':/

      def humanize_check_name(check_name)
        check_name.to_s.tr("_", " ")
      end

      def diagnose_status_styles(ok)
        if ok
          {
            card: "border-green-200 bg-green-50",
            header: "border-green-200 hover:bg-green-100",
            badge: "bg-green-600 text-white",
            count: "bg-green-200 text-green-900",
            body: "text-green-900",
          }
        else
          {
            card: "border-red-200 bg-red-50",
            header: "border-red-200 hover:bg-red-100",
            badge: "bg-red-600 text-white",
            count: "bg-red-200 text-red-900",
            body: "text-red-900",
          }
        end
      end

      def diagnose_finding_count(message, check_name: nil)
        text = message.to_s.strip
        return nil if text.blank?

        count, noun = case diagnose_message_kind(text, check_name)
          when :hot then [hot_sections(text).first.size, "table"]
          when :list then [list_items(text).size, "item"]
          else return nil
          end

        return nil if count.zero?

        { count: count, label: count == 1 ? noun : noun.pluralize }
      end

      def format_diagnose_message(message, check_name: nil)
        text = message.to_s.strip
        return "".html_safe if text.blank?

        case diagnose_message_kind(text, check_name)
        when :hot then format_hot_diagnose_message(text)
        when :list then format_list_diagnose_message(text)
        else plain_diagnose_message(text)
        end
      end

      private

      def diagnose_message_kind(text, check_name)
        return :hot if HOT_CHECKS.include?(check_name&.to_sym) || text.match?(/'[^\n']+':\n/)
        # Multi-item lists use ",\n"; single-item FK-style messages use "detected: item."
        return :list if text.include?(",\n") || text.match?(/detected:(\n| \S)/)

        :plain
      end

      def plain_diagnose_message(text)
        content_tag(:div, simple_format(h(text), {}, sanitize: false), class: "whitespace-pre-wrap leading-relaxed")
      end

      # Adds the toggle hooks read by pg-extras-ui.js to items past the collapse threshold.
      def collapsible_attributes(base_class, hidden)
        return { class: base_class } unless hidden

        { class: "#{base_class} hidden", data: { pg_extras_collapse: true } }
      end

      def collapse_toggle_button(count, noun)
        content_tag(
          :button,
          "Show all #{count} #{noun}",
          type: "button",
          class: "mt-3 text-sm font-semibold text-blue-700 hover:text-blue-900 underline",
          data: {
            pg_extras_collapse_toggle: true,
            expanded_label: "Show fewer #{noun}",
            collapsed_label: "Show all #{count} #{noun}",
          },
        )
      end

      def format_list_diagnose_message(text)
        items = list_items(text)
        return plain_diagnose_message(text) if items.empty?

        parts = [
          content_tag(:ul, class: "list-disc pl-5 space-y-1") do
            safe_join(
              items.each_with_index.map do |item, index|
                content_tag(:li, item, collapsible_attributes("leading-snug", index >= COLLAPSE_AFTER))
              end,
            )
          end,
        ]

        parts << collapse_toggle_button(items.size, "items") if items.size > COLLAPSE_AFTER

        safe_join(parts)
      end

      # The leading "... detected:" sentence is dropped: the card title already names the check.
      def list_items(text)
        remainder = if text.include?(":\n")
            text.split(":\n", 2).last
          elsif text.include?(": ")
            text.split(": ", 2).last
          else
            text
          end

        remainder
          .sub(/\.\z/, "")
          .split(",\n")
          .flat_map { |chunk| chunk.split(/\n(?!')/) }
          .map { |item| item.strip.sub(/,\z/, "").sub(/\.\z/, "") }
          .reject(&:blank?)
      end

      # Returns [per-table blocks, explanatory prose], minus the summary line.
      def hot_sections(text)
        paragraphs = text.split(/\n{2,}/).map(&:strip).reject(&:blank?)
        paragraphs.drop(1).partition { |paragraph| paragraph.match?(HOT_TABLE_BLOCK) }
      end

      def format_hot_diagnose_message(text)
        table_blocks, prose = hot_sections(text)
        return plain_diagnose_message(text) if table_blocks.empty? && prose.empty?

        parts = []

        if table_blocks.any?
          parts << content_tag(:div, class: "space-y-3") do
            safe_join(
              table_blocks.each_with_index.map do |block, index|
                render_hot_table_block(block, hidden: index >= COLLAPSE_AFTER)
              end,
            )
          end

          parts << collapse_toggle_button(table_blocks.size, "tables") if table_blocks.size > COLLAPSE_AFTER
        end

        parts << render_hot_info_callout(prose) if prose.any?

        safe_join(parts)
      end

      def render_hot_info_callout(prose)
        icon = <<~SVG.html_safe
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-5 h-5 flex-shrink-0 mt-0.5" aria-hidden="true">
            <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
          </svg>
        SVG

        content_tag(
          :aside,
          class: "mt-4 flex gap-3 rounded-lg border border-blue-200 bg-blue-50 px-4 py-3 text-sm text-blue-900",
          role: "note",
        ) do
          body = content_tag(:div, class: "min-w-0 space-y-2 leading-relaxed") do
            safe_join([
              content_tag(:p, "Why this matters", class: "font-semibold"),
              *prose.map { |paragraph| content_tag(:p, paragraph) },
            ])
          end

          safe_join([icon, body])
        end
      end

      def render_hot_table_block(block, hidden: false)
        lines = block.split("\n").map(&:strip).reject(&:blank?)
        title_line = lines.shift.to_s
        table_name = title_line[/'\K[^']+/] || title_line.sub(/:\z/, "")

        attributes = collapsible_attributes("rounded-lg border border-gray-300 bg-white px-3 py-2", hidden)

        content_tag(:div, attributes) do
          title = content_tag(:div, table_name, class: "font-semibold text-gray-900 mb-1")
          metrics = content_tag(:dl, class: "grid grid-cols-1 gap-1 text-sm") do
            safe_join(
              lines.filter_map do |line|
                key, value = line.split(":", 2)
                next if key.blank? || value.blank?

                content_tag(:div, class: "flex flex-wrap gap-x-2") do
                  safe_join([
                    content_tag(:dt, "#{key.strip}:", class: "font-medium text-gray-700"),
                    content_tag(:dd, value.strip, class: "text-gray-800"),
                  ])
                end
              end,
            )
          end

          safe_join([title, metrics])
        end
      end
    end
  end
end
