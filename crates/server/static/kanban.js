// Causelog board — view toggles + drag-and-drop status changes.
(function () {
  'use strict';

  // ── View toggles (Board / List per entity section) ────────────────────
  document.querySelectorAll('.view-toggle').forEach(function (group) {
    var entity = group.getAttribute('data-entity');
    var boardView = document.querySelector('.board-view[data-entity="' + entity + '"]');
    var listView = document.querySelector('.list-view[data-entity="' + entity + '"]');
    if (!boardView || !listView) return;

    // Restore saved preference
    var saved = localStorage.getItem('board-view-' + entity);
    if (saved === 'list') {
      boardView.hidden = true;
      listView.hidden = false;
      group.querySelector('[data-view="list"]').classList.add('on');
      group.querySelector('[data-view="board"]').classList.remove('on');
    }

    group.querySelectorAll('.toggle-btn').forEach(function (btn) {
      btn.addEventListener('click', function () {
        var view = btn.getAttribute('data-view');
        group.querySelectorAll('.toggle-btn').forEach(function (b) { b.classList.remove('on'); });
        btn.classList.add('on');
        if (view === 'list') {
          boardView.hidden = true;
          listView.hidden = false;
        } else {
          listView.hidden = true;
          boardView.hidden = false;
        }
        localStorage.setItem('board-view-' + entity, view);
      });
    });
  });

  // ── Drag and drop ─────────────────────────────────────────────────────
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
          window.location.reload();
        }
      }).catch(function () {
        window.location.reload();
      });
    });
  });

  function updateCounts(entity) {
    var entityMap = {
      goal: 'goals',
      decision: 'decisions',
      experiment: 'experiments'
    };
    var tabName = entityMap[entity] || entity;
    document.querySelectorAll('.board-view[data-entity="' + tabName + '"] .board-column').forEach(function (col) {
      var count = col.querySelectorAll('.board-card').length;
      var badge = col.querySelector('.board-count');
      if (badge) badge.textContent = count;
    });
  }
})();
