// Causelog — inline editable fields.
(function () {
  'use strict';

  var csrfMeta = document.querySelector('meta[name="csrf-token"]');
  if (!csrfMeta) return;
  var csrfToken = csrfMeta.getAttribute('content');

  // ── Activate edit mode ───────────────────────────────────────────────
  document.addEventListener('click', function (e) {
    var display = e.target.closest('.editable-display');
    if (!display) return;
    var container = display.closest('.editable');
    if (!container || container.classList.contains('active')) return;

    // Close any other active editables first
    document.querySelectorAll('.editable.active').forEach(closeEditable);

    container.classList.add('active');
    var input = container.querySelector('.editable-edit input, .editable-edit textarea, .editable-edit select');
    if (input) {
      input.focus();
      if (input.select) input.select();
    }
  });

  // ── Save ─────────────────────────────────────────────────────────────
  function saveEditable(container) {
    var field = container.getAttribute('data-field');
    var entity = container.getAttribute('data-entity');
    var id = container.getAttribute('data-id');
    var apiMap = {
      goal: '/api/goals/',
      note: '/api/notes/',
      experiment: '/api/experiments/',
      project: '/api/projects/',
      decision: '/api/decisions/',
    };
    var baseUrl = apiMap[entity];
    if (!baseUrl) return;

    var payload = { csrf_token: csrfToken };
    var input = container.querySelector('.editable-edit input, .editable-edit textarea, .editable-edit select');
    if (input) {
      payload[field] = input.value;
    }

    // For decision resolve forms, gather all fields
    if (entity === 'decision' && field === 'resolve') {
      var form = container.querySelector('form');
      if (form) {
        var fd = new FormData(form);
        payload = { csrf_token: csrfToken };
        fd.forEach(function (v, k) { payload[k] = v; });
      }
      baseUrl += id + '/resolve';
      id = '';
    } else {
      baseUrl += id;
    }

    var errorEl = container.querySelector('.editable-error');
    if (errorEl) errorEl.remove();

    container.classList.add('editable-saving');

    fetch(baseUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify(payload),
    })
      .then(function (res) {
        return res.json().then(function (data) {
          if (!res.ok) throw new Error(data.error || 'Save failed');
          return data;
        });
      })
      .then(function (data) {
        container.classList.remove('active', 'editable-saving');
        // Update display
        if (data.title !== undefined) {
          var displayText = container.querySelector('.editable-display');
          if (displayText) {
            // Handle h1 inside display
            var h1 = displayText.querySelector('h1');
            if (h1) h1.textContent = data.title;
            else displayText.textContent = data.title;
          }
        }
        if (data.body_html !== undefined) {
          var proseDisplay = container.querySelector('.editable-display .prose');
          if (proseDisplay) proseDisplay.innerHTML = data.body_html;
        }
        if (data.context_html !== undefined) {
          var ctxDisplay = container.querySelector('.editable-display .prose');
          if (ctxDisplay) ctxDisplay.innerHTML = data.context_html;
        }
        if (data.hypothesis_html !== undefined) {
          var hypDisplay = container.querySelector('[data-display="hypothesis"] .prose');
          if (hypDisplay) hypDisplay.innerHTML = data.hypothesis_html;
        }
        if (data.result_html !== undefined) {
          var resDisplay = container.querySelector('[data-display="result"] .prose');
          if (resDisplay) resDisplay.innerHTML = data.result_html;
        }
        if (data.lesson_html !== undefined) {
          var lesDisplay = container.querySelector('[data-display="lesson"] .prose');
          if (lesDisplay) lesDisplay.innerHTML = data.lesson_html;
        }
        if (data.status !== undefined) {
          var tag = container.querySelector('.editable-display .tag');
          if (tag) {
            tag.textContent = data.status;
            tag.className = 'tag status-' + data.status;
          }
          // Also update the page header status tag if present
          var headerTag = document.querySelector('.meta-card .tag');
          if (headerTag && container.getAttribute('data-field') === 'status') {
            headerTag.textContent = data.status;
            headerTag.className = 'tag status-' + data.status;
          }
        }
        if (data.assigned_to_name !== undefined) {
          var assignDisplay = container.querySelector('.editable-display');
          if (assignDisplay) {
            var nameSpan = assignDisplay.querySelector('.assigned-name');
            if (nameSpan) nameSpan.textContent = data.assigned_to_name;
          }
        }
        if (data.summary !== undefined) {
          var sumDisplay = container.querySelector('.editable-display');
          if (sumDisplay) sumDisplay.textContent = data.summary;
        }
      })
      .catch(function (err) {
        container.classList.remove('editable-saving');
        var errDiv = document.createElement('div');
        errDiv.className = 'editable-error';
        errDiv.textContent = err.message;
        container.appendChild(errDiv);
      });
  }

  // ── Cancel ───────────────────────────────────────────────────────────
  function closeEditable(container) {
    container.classList.remove('active', 'editable-saving');
    var errEl = container.querySelector('.editable-error');
    if (errEl) errEl.remove();
    // Revert input to original value
    var input = container.querySelector('.editable-edit input, .editable-edit textarea, .editable-edit select');
    if (input && input.hasAttribute('data-original')) {
      input.value = input.getAttribute('data-original');
    }
  }

  // ── Event delegation ─────────────────────────────────────────────────
  document.addEventListener('click', function (e) {
    if (e.target.classList.contains('editable-save')) {
      var container = e.target.closest('.editable');
      if (container) saveEditable(container);
    }
    if (e.target.classList.contains('editable-cancel')) {
      var container = e.target.closest('.editable');
      if (container) closeEditable(container);
    }
  });

  // Enter to save (inputs), Escape to cancel
  document.addEventListener('keydown', function (e) {
    var container = e.target.closest('.editable');
    if (!container || !container.classList.contains('active')) return;

    if (e.key === 'Escape') {
      e.preventDefault();
      closeEditable(container);
      return;
    }

    if (e.key === 'Enter' && e.target.tagName !== 'TEXTAREA') {
      e.preventDefault();
      saveEditable(container);
    }
  });

  // Ctrl+Enter to save textareas
  document.addEventListener('keydown', function (e) {
    if (e.key !== 'Enter' || !e.ctrlKey) return;
    var container = e.target.closest('.editable');
    if (!container || !container.classList.contains('active')) return;
    if (e.target.tagName !== 'TEXTAREA') return;
    e.preventDefault();
    saveEditable(container);
  });

  // ── Store original values for cancel ─────────────────────────────────
  document.querySelectorAll('.editable').forEach(function (container) {
    var input = container.querySelector('.editable-edit input, .editable-edit textarea, .editable-edit select');
    if (input) input.setAttribute('data-original', input.value);
  });
})();
