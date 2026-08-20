// Causelog — inline editable fields.
(function () {
  'use strict';

  var csrfMeta = document.querySelector('meta[name="csrf-token"]');
  if (!csrfMeta) return;
  var csrfToken = csrfMeta.getAttribute('content');

  // ── Single-field activate on click ────────────────────────────────────
  document.addEventListener('click', function (e) {
    var display = e.target.closest('.editable-display');
    if (!display) return;
    var container = display.closest('.editable');
    if (!container || container.classList.contains('active')) return;
    // Don't single-activate if we're in all-edit mode
    if (document.querySelector('.editable.active')) return;

    container.classList.add('active');
    showDoneBar();
    setEditMode(true);
    focusEditable(container);
  });

  // ── Edit all fields at once ───────────────────────────────────────────
  function editAllEditable() {
    var containers = document.querySelectorAll('.editable:not(.active)');
    containers.forEach(function (c) {
      c.classList.add('active');
      // Store original for cancel
      var input = c.querySelector('.editable-edit input, .editable-edit textarea, .editable-edit select');
      if (input && !input.hasAttribute('data-original')) {
        input.setAttribute('data-original', input.value);
      }
    });
    showDoneBar();
    setEditMode(true);
    // Focus the first editable field on the page
    var first = document.querySelector('.editable.active');
    if (first) focusEditable(first);
  }

  // ── Cancel all fields at once ─────────────────────────────────────────
  function cancelAllEditable() {
    document.querySelectorAll('.editable.active').forEach(closeEditable);
    setEditMode(false);
    hideDoneBar();
  }

  // ── Done editing bar ──────────────────────────────────────────────────
  function showDoneBar() {
    var bar = document.getElementById('done-editing-bar');
    if (bar) bar.classList.add('active');
  }
  function hideDoneBar() {
    var bar = document.getElementById('done-editing-bar');
    if (bar) bar.classList.remove('active');
  }
  function anyActive() {
    return document.querySelectorAll('.editable.active').length > 0;
  }

  // ── Dropdown toggle between View / Edit ───────────────────────────────
  function setEditMode(editing) {
    var dd = document.getElementById('action-dropdown');
    if (!dd) return;
    dd.querySelector('summary').textContent = editing ? 'Edit' : 'View';
    var editLink = dd.querySelector('[data-action="edit-all"]');
    var viewLink = dd.querySelector('[data-action="cancel-all"]');
    if (editLink) editLink.classList.toggle('hidden', editing);
    if (viewLink) viewLink.classList.toggle('hidden', !editing);
  }

  // ── Focus helper ──────────────────────────────────────────────────────
  function focusEditable(container) {
    var input = container.querySelector('.editable-edit input, .editable-edit textarea, .editable-edit select');
    if (input) {
      input.focus();
      if (input.select) input.select();
    }
  }

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
        // Update data-original to match saved value
        var savedInput = container.querySelector('.editable-edit input, .editable-edit textarea, .editable-edit select');
        if (savedInput) savedInput.setAttribute('data-original', savedInput.value);
        // Update display — only update content relevant to the saved field
        var field = container.getAttribute('data-field');
        if (field === 'title' && data.title !== undefined) {
          var displayText = container.querySelector('.editable-display');
          if (displayText) {
            var h1 = displayText.querySelector('h1');
            if (h1) h1.textContent = data.title;
            else displayText.textContent = data.title;
          }
        }
        if (field === 'body' && data.body_html !== undefined) {
          var proseDisplay = container.querySelector('.editable-display .prose');
          if (proseDisplay) proseDisplay.innerHTML = data.body_html;
        }
        if (field === 'context' && data.context_html !== undefined) {
          var ctxDisplay = container.querySelector('.editable-display .prose');
          if (ctxDisplay) ctxDisplay.innerHTML = data.context_html;
        }
        if (field === 'hypothesis' && data.hypothesis_html !== undefined) {
          var hypDisplay = container.querySelector('[data-display="hypothesis"] .prose');
          if (hypDisplay) hypDisplay.innerHTML = data.hypothesis_html;
        }
        if (field === 'result' && data.result_html !== undefined) {
          var resDisplay = container.querySelector('[data-display="result"] .prose');
          if (resDisplay) resDisplay.innerHTML = data.result_html;
        }
        if (field === 'lesson' && data.lesson_html !== undefined) {
          var lesDisplay = container.querySelector('[data-display="lesson"] .prose');
          if (lesDisplay) lesDisplay.innerHTML = data.lesson_html;
        }
        if (field === 'status' && data.status !== undefined) {
          var tag = container.querySelector('.editable-display .tag');
          if (tag) {
            tag.textContent = data.status;
            tag.className = 'tag status-' + data.status;
          }
          var headerTag = document.querySelector('.meta-card .tag');
          if (headerTag) {
            headerTag.textContent = data.status;
            headerTag.className = 'tag status-' + data.status;
          }
        }
        if (field === 'assigned_to' && data.assigned_to_name !== undefined) {
          var assignDisplay = container.querySelector('.editable-display');
          if (assignDisplay) {
            var nameSpan = assignDisplay.querySelector('.assigned-name');
            if (nameSpan) nameSpan.textContent = data.assigned_to_name;
          }
        }
        if (field === 'summary' && data.summary !== undefined) {
          var sumDisplay = container.querySelector('.editable-display');
          if (sumDisplay) sumDisplay.textContent = data.summary;
        }
        if (!anyActive()) { setEditMode(false); hideDoneBar(); }
      })
      .catch(function (err) {
        container.classList.remove('editable-saving');
        var errDiv = document.createElement('div');
        errDiv.className = 'editable-error';
        errDiv.textContent = err.message;
        container.appendChild(errDiv);
      });
  }

  // ── Cancel single field ──────────────────────────────────────────────
  function closeEditable(container) {
    container.classList.remove('active', 'editable-saving');
    var errEl = container.querySelector('.editable-error');
    if (errEl) errEl.remove();
    var input = container.querySelector('.editable-edit input, .editable-edit textarea, .editable-edit select');
    if (input && input.hasAttribute('data-original')) {
      input.value = input.getAttribute('data-original');
    }
  }

  // ── Event delegation ─────────────────────────────────────────────────
  document.addEventListener('click', function (e) {
    // Edit all / Cancel all from dropdown
    if (e.target.matches('[data-action="edit-all"]')) {
      e.preventDefault();
      // Close any open nav-dropdown
      var dd = e.target.closest('.nav-dropdown');
      if (dd) dd.removeAttribute('open');
      editAllEditable();
      return;
    }
    if (e.target.matches('[data-action="cancel-all"]')) {
      e.preventDefault();
      var dd = e.target.closest('.nav-dropdown');
      if (dd) dd.removeAttribute('open');
      cancelAllEditable();
      return;
    }
    // Individual field save / cancel
    if (e.target.classList.contains('editable-save')) {
      var container = e.target.closest('.editable');
      if (container) saveEditable(container);
    }
    if (e.target.classList.contains('editable-cancel')) {
      var container = e.target.closest('.editable');
      if (container) {
        closeEditable(container);
        if (!anyActive()) { setEditMode(false); hideDoneBar(); }
      }
    }
  });

  // ── Keyboard shortcuts ────────────────────────────────────────────────
  document.addEventListener('keydown', function (e) {
    var container = e.target.closest('.editable');
    if (!container || !container.classList.contains('active')) return;

    if (e.key === 'Escape') {
      e.preventDefault();
      closeEditable(container);
      if (!anyActive()) { setEditMode(false); hideDoneBar(); }
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

  // ── Unsaved changes guard ────────────────────────────────────────────
  function isDirty() {
    var containers = document.querySelectorAll('.editable.active');
    for (var i = 0; i < containers.length; i++) {
      var input = containers[i].querySelector('.editable-edit input, .editable-edit textarea, .editable-edit select');
      if (input && input.value !== input.getAttribute('data-original')) return true;
    }
    return false;
  }

  window.addEventListener('beforeunload', function (e) {
    if (isDirty()) {
      e.preventDefault();
      e.returnValue = '';
    }
  });

  // ── Store original values on load ────────────────────────────────────
  document.querySelectorAll('.editable').forEach(function (container) {
    var input = container.querySelector('.editable-edit input, .editable-edit textarea, .editable-edit select');
    if (input) input.setAttribute('data-original', input.value);
  });
})();
