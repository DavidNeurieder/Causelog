/* Story editor drag ordering. Rows inside a `.drag-list` can be rearranged
   by grabbing the `.drag-handle`; on drop the container's order is written
   back into its hidden `name` input (a comma-separated id list). */
(function () {
  var dragging = null;

  document.querySelectorAll('.drag-list').forEach(function (list) {
    var orderInput = document.querySelector(
      'input[name="' + list.getAttribute('data-order-input') + '"]'
    );

    list.addEventListener('dragover', function (e) {
      if (!dragging) return;
      e.preventDefault();
      var after = getDragAfterElement(list, e.clientY);
      if (after == null) list.appendChild(dragging);
      else list.insertBefore(dragging, after);
    });

    list.addEventListener('dragend', function () {
      dragging = null;
      list.classList.remove('dragging-list');
      if (orderInput) {
        orderInput.value = Array.prototype.map
          .call(list.querySelectorAll('.drag-row'), function (row) {
            return row.getAttribute('data-id');
          })
          .join(',');
      }
    });
  });

  document.querySelectorAll('.drag-handle[data-drag="true"]').forEach(function (handle) {
    handle.addEventListener('dragstart', function (e) {
      dragging = handle.closest('.drag-row');
      dragging.classList.add('dragging');
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/plain', draggedId());
    });
    handle.addEventListener('dragend', function () {
      if (dragging) dragging.classList.remove('dragging');
      dragging = null;
    });
    // A handle is the only clickable drag surface; prevent text selection.
    handle.addEventListener('mousedown', function (e) {
      if (e.detail > 1) e.preventDefault();
    });
  });

  function draggedId() {
    return dragging ? dragging.getAttribute('data-id') : '';
  }

  function getDragAfterElement(container, y) {
    var els = Array.prototype.slice.call(container.querySelectorAll('.drag-row:not(.dragging)'), 0);
    return els.reduce(
      function (closest, child) {
        var box = child.getBoundingClientRect();
        var after = y - box.top - box.height / 2;
        if (after < 0 && after > closest.offset) {
          return { offset: after, element: child };
        }
        return closest;
      },
      { offset: Number.NEGATIVE_INFINITY }
    ).element;
  }
})();