// Causelog board — drag-and-drop status changes.
(function () {
  'use strict';

  var csrfToken = document.querySelector('meta[name="csrf-token"]');
  if (!csrfToken) return;
  var token = csrfToken.getAttribute('content');

  // Add entity attribute to each card based on its link href.
  document.querySelectorAll('.board-card').forEach(function (card) {
    var link = card.querySelector('a');
    if (!link) return;
    var href = link.getAttribute('href') || '';
    if (href.startsWith('/goals/')) card.setAttribute('data-entity', 'goal');
    else if (href.startsWith('/decisions/')) card.setAttribute('data-entity', 'decision');
    else if (href.startsWith('/experiments/')) card.setAttribute('data-entity', 'experiment');
  });

  // Drag start/end
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

  // Drop targets
  document.querySelectorAll('.board-column-body').forEach(function (col) {
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

      var card = document.querySelector(
        '.board-card[data-entity="' + data.entity + '"][data-id="' + data.id + '"]'
      );
      if (!card) return;

      // Optimistic move
      col.appendChild(card);

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
    document.querySelectorAll('.board-column').forEach(function (col) {
      var body = col.querySelector('.board-column-body');
      if (!body) return;
      var count = body.querySelectorAll('.board-card').length;
      var badge = col.querySelector('.board-count');
      if (badge) badge.textContent = count;
    });
  }
})();
