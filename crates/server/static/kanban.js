// Causelog kanban board — drag-and-drop status changes + tab switching.
(function () {
  'use strict';

  // ── Tab switching ──────────────────────────────────────────────────────
  document.querySelectorAll('.board-tab').forEach(function (btn) {
    btn.addEventListener('click', function () {
      document.querySelectorAll('.board-tab').forEach(function (b) { b.classList.remove('on'); });
      btn.classList.add('on');
      var tab = btn.getAttribute('data-tab');
      document.querySelectorAll('.board-section').forEach(function (s) {
        s.hidden = s.getAttribute('data-tab') !== tab;
      });
    });
  });

  // ── Drag and drop ──────────────────────────────────────────────────────
  var csrfToken = document.querySelector('meta[name="csrf-token"]');
  if (!csrfToken) return;
  var token = csrfToken.getAttribute('content');

  document.querySelectorAll('.board-card').forEach(function (card) {
    card.addEventListener('dragstart', function (e) {
      card.classList.add('dragging');
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/plain', JSON.stringify({
        entity: card.getAttribute('data-entity'),
        id: card.getAttribute('data-id')
      }));
    });
    card.addEventListener('dragend', function () {
      card.classList.remove('dragging');
    });
  });

  document.querySelectorAll('.board-column').forEach(function (col) {
    col.addEventListener('dragover', function (e) {
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
      col.classList.add('drag-over');
    });
    col.addEventListener('dragleave', function () {
      col.classList.remove('drag-over');
    });
    col.addEventListener('drop', function (e) {
      e.preventDefault();
      col.classList.remove('drag-over');
      var data;
      try { data = JSON.parse(e.dataTransfer.getData('text/plain')); } catch (_) { return; }
      var newStatus = col.getAttribute('data-status');
      var cards = col.querySelector('.board-cards');

      // Find the dragged card in the DOM
      var card = document.querySelector(
        '.board-card[data-entity="' + data.entity + '"][data-id="' + data.id + '"]'
      );
      if (!card) return;

      // Optimistic move
      cards.appendChild(card);

      // Update counts
      updateCounts(card.getAttribute('data-entity'));

      // POST to API
      fetch('/api/status', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token
        },
        body: JSON.stringify({ entity: data.entity, id: data.id, status: newStatus })
      }).then(function (res) {
        if (!res.ok) {
          // Revert on error — reload is simplest
          window.location.reload();
        }
      }).catch(function () {
        window.location.reload();
      });
    });
  });

  function updateCounts(entity) {
    document.querySelectorAll('.board-section[data-entity="' + entity + '"] .board-column').forEach(function (col) {
      var count = col.querySelectorAll('.board-card').length;
      var badge = col.querySelector('.board-count');
      if (badge) badge.textContent = count;
    });
  }
})();
