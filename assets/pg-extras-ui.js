(function () {
  "use strict";

  // Returns false when the element is missing or already wired up.
  function bindOnce(element) {
    if (!element || element.dataset.pgExtrasBound === "true") return false;
    element.dataset.pgExtrasBound = "true";
    return true;
  }

  // "Show all N items" toggles inside a diagnose card body.
  function initCollapseToggles(root) {
    root.querySelectorAll("[data-pg-extras-collapse-toggle]").forEach(function (button) {
      if (!bindOnce(button)) return;

      button.setAttribute("aria-expanded", "false");

      button.addEventListener("click", function () {
        var parent = button.parentElement;
        if (!parent) return;

        var expanded = button.getAttribute("aria-expanded") !== "true";

        parent.querySelectorAll("[data-pg-extras-collapse]").forEach(function (target) {
          target.classList.toggle("hidden", !expanded);
        });

        button.setAttribute("aria-expanded", expanded ? "true" : "false");
        button.textContent = expanded
          ? button.dataset.expandedLabel
          : button.dataset.collapsedLabel;
      });
    });
  }

  function setCardExpanded(card, expanded) {
    var toggle = card.querySelector("[data-pg-extras-card-toggle]");
    var body = card.querySelector("[data-pg-extras-card-body]");
    var chevron = card.querySelector("[data-pg-extras-card-chevron]");
    if (!toggle || !body) return;

    toggle.setAttribute("aria-expanded", expanded ? "true" : "false");
    toggle.classList.toggle("border-b", expanded);
    body.classList.toggle("hidden", !expanded);
    if (chevron) {
      chevron.textContent = expanded ? "▾" : "▸";
    }
  }

  function bindBulkCardToggle(root, selector, expanded) {
    var button = root.querySelector(selector);
    if (!bindOnce(button)) return;

    button.addEventListener("click", function () {
      root.querySelectorAll("[data-pg-extras-card]").forEach(function (card) {
        setCardExpanded(card, expanded);
      });
    });
  }

  function initDiagnoseCards(root) {
    root.querySelectorAll("[data-pg-extras-card]").forEach(function (card) {
      var toggle = card.querySelector("[data-pg-extras-card-toggle]");
      if (!bindOnce(toggle)) return;

      toggle.addEventListener("click", function () {
        setCardExpanded(card, toggle.getAttribute("aria-expanded") !== "true");
      });
    });

    bindBulkCardToggle(root, "[data-pg-extras-cards-expand-all]", true);
    bindBulkCardToggle(root, "[data-pg-extras-cards-collapse-all]", false);
  }

  function visibleOptions(list) {
    return Array.prototype.slice.call(
      list.querySelectorAll("[data-pg-extras-combobox-option]:not(.hidden)")
    );
  }

  function setActiveOption(options, index) {
    options.forEach(function (option, i) {
      option.classList.toggle("bg-blue-100", i === index);
    });

    if (index >= 0 && options[index]) {
      options[index].scrollIntoView({ block: "nearest" });
    }
  }

  function openList(combobox, list, input) {
    list.classList.remove("hidden");
    input.setAttribute("aria-expanded", "true");
    combobox.dataset.open = "true";
  }

  function closeList(combobox, list, input) {
    list.classList.add("hidden");
    input.setAttribute("aria-expanded", "false");
    combobox.dataset.open = "false";
  }

  function filterOptions(list, query) {
    var normalized = (query || "").trim().toLowerCase();

    list.querySelectorAll("[data-pg-extras-combobox-option]").forEach(function (option) {
      var label = (option.dataset.label || "").toLowerCase();
      option.classList.toggle("hidden", normalized !== "" && label.indexOf(normalized) === -1);
    });
  }

  function selectOption(form, input, valueInput, option) {
    if (!option || option.dataset.disabled === "true") return;

    input.value = option.dataset.label || option.dataset.value || "diagnose";
    valueInput.value = option.dataset.value || "";
    form.submit();
  }

  function closeComboboxesOutside(target) {
    document.querySelectorAll("[data-pg-extras-combobox]").forEach(function (combobox) {
      if (combobox.contains(target)) return;

      var input = combobox.querySelector("[data-pg-extras-combobox-input]");
      var list = combobox.querySelector("[data-pg-extras-combobox-list]");
      if (input && list) closeList(combobox, list, input);
    });
  }

  function initCombobox(combobox) {
    if (!bindOnce(combobox)) return;

    var form = combobox.closest("form");
    var input = combobox.querySelector("[data-pg-extras-combobox-input]");
    var list = combobox.querySelector("[data-pg-extras-combobox-list]");
    var valueInput = combobox.querySelector("[data-pg-extras-combobox-value]");
    var toggle = combobox.querySelector("[data-pg-extras-combobox-toggle]");
    var activeIndex = -1;

    if (!form || !input || !list || !valueInput) return;

    function showAllOptions() {
      filterOptions(list, "");
      openList(combobox, list, input);
      activeIndex = -1;
      setActiveOption(visibleOptions(list), activeIndex);
    }

    function moveActive(delta) {
      var options = visibleOptions(list);
      if (!options.length) return;

      if (activeIndex === -1) {
        activeIndex = delta > 0 ? 0 : options.length - 1;
      } else {
        activeIndex = (activeIndex + delta + options.length) % options.length;
      }

      // Skip disabled options, unless every remaining option is disabled.
      var guard = 0;
      while (options[activeIndex].dataset.disabled === "true" && guard < options.length) {
        activeIndex = (activeIndex + delta + options.length) % options.length;
        guard += 1;
      }

      setActiveOption(options, activeIndex);
    }

    // Opening on click rather than focus keeps the list closed on autofocus.
    input.addEventListener("focus", function () {
      input.select();
    });

    input.addEventListener("click", showAllOptions);

    input.addEventListener("input", function () {
      filterOptions(list, input.value);
      openList(combobox, list, input);
      activeIndex = -1;
      setActiveOption(visibleOptions(list), activeIndex);
    });

    input.addEventListener("keydown", function (event) {
      if (event.key === "ArrowDown" || event.key === "ArrowUp") {
        event.preventDefault();
        openList(combobox, list, input);
        moveActive(event.key === "ArrowDown" ? 1 : -1);
      } else if (event.key === "Enter") {
        var options = visibleOptions(list);
        if (combobox.dataset.open === "true" && options[activeIndex]) {
          event.preventDefault();
          selectOption(form, input, valueInput, options[activeIndex]);
        }
      } else if (event.key === "Escape") {
        closeList(combobox, list, input);
        activeIndex = -1;
      }
    });

    if (toggle) {
      toggle.addEventListener("click", function (event) {
        event.preventDefault();

        if (combobox.dataset.open === "true") {
          closeList(combobox, list, input);
        } else {
          showAllOptions();
          input.focus();
        }
      });
    }

    // mousedown fires before the input blurs, so the click always lands on an option.
    list.addEventListener("mousedown", function (event) {
      event.preventDefault();
      selectOption(form, input, valueInput, event.target.closest("[data-pg-extras-combobox-option]"));
    });
  }

  function initAll() {
    initCollapseToggles(document);
    initDiagnoseCards(document);
    document.querySelectorAll("[data-pg-extras-combobox]").forEach(initCombobox);
  }

  document.addEventListener("click", function (event) {
    closeComboboxesOutside(event.target);
  });

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initAll);
  } else {
    initAll();
  }
})();
