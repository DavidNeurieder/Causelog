/* StoryChain node side panel.
   Clicking a chain node opens a drawer with the entity's details instead of
   navigating; "View full record" still follows the node's link. */
(function () {
  var DETAILS_ROW_SELECTOR = '.panel-row';

  function buildPanel(node) {
    var kind = node.getAttribute('data-node-kind');
    var title = node.querySelector('.chain-title');
    var titleText = title ? title.textContent.trim() : kind;
    var link = node.getAttribute('data-node-link') || (title ? title.getAttribute('href') : '#');
    var details = node.querySelector('.node-details');

    var panel = document.createElement('div');
    panel.className = 'story-panel';

    var head = document.createElement('div');
    head.className = 'story-panel-head';
    var k = document.createElement('span');
    k.className = 'story-mark';
    k.textContent = kind;
    head.appendChild(k);
    var h = document.createElement('h2');
    h.textContent = titleText;
    head.appendChild(h);
    panel.appendChild(head);

    if (details) {
      var rows = details.querySelectorAll(DETAILS_ROW_SELECTOR);
      rows.forEach(function (row) {
        var label = row.querySelector('span:first-child');
        var value = row.querySelector('span:last-child');
        if (!label || !value) return;
        var div = document.createElement('div');
        div.className = 'panel-row';
        var v = document.createElement('span');
        v.className = 'muted small';
        v.textContent = label.textContent;
        var w = document.createElement('span');
        w.textContent = value.textContent;
        div.appendChild(v);
        div.appendChild(w);
        panel.appendChild(div);
      });
    }

    var a = document.createElement('a');
    a.className = 'btn';
    a.href = link;
    a.textContent = 'View full record';
    panel.appendChild(a);
    return panel;
  }

  function open() {
    var overlay = document.createElement('div');
    overlay.className = 'side-overlay';
    document.body.appendChild(overlay);
    var drawer = document.createElement('aside');
    drawer.id = 'story-drawer';
    drawer.className = 'side-drawer';
    drawer.setAttribute('aria-label', 'Story node');
    document.body.appendChild(drawer);
    requestAnimationFrame(function () {
      drawer.classList.add('open');
    });
  }

  function close() {
    var drawer = document.getElementById('story-drawer');
    var overlay = document.querySelector('.side-overlay');
    if (drawer) drawer.remove();
    if (overlay) overlay.remove();
  }

  function show(node) {
    close();
    open();
    var drawer = document.getElementById('story-drawer');
    drawer.appendChild(buildPanel(node));
  }

  // Side panel from raw entity data (graph nodes).
  function showEntity(kind, title, link) {
    close();
    open();
    var drawer = document.getElementById('story-drawer');
    var panel = document.createElement('div');
    panel.className = 'story-panel';
    var head = document.createElement('div');
    head.className = 'story-panel-head';
    var k = document.createElement('span');
    k.className = 'story-mark';
    k.textContent = kind;
    head.appendChild(k);
    var h = document.createElement('h2');
    h.textContent = title;
    head.appendChild(h);
    panel.appendChild(head);
    var a = document.createElement('a');
    a.className = 'btn';
    a.href = link;
    a.textContent = 'View full record';
    panel.appendChild(a);
    drawer.appendChild(panel);
  }

  document.addEventListener('click', function (e) {
    var node = e.target.closest ? e.target.closest('.chain-node') : null;
    if (node) {
      e.preventDefault();
      e.stopPropagation();
      show(node);
      return;
    }
    var gnode = e.target.closest ? e.target.closest('.graph-node') : null;
    if (gnode) {
      e.preventDefault();
      e.stopPropagation();
      showEntity(
        gnode.getAttribute('data-node-kind'),
        gnode.getAttribute('data-node-title'),
        gnode.getAttribute('data-node-link')
      );
      return;
    }
    if (e.target.classList && e.target.classList.contains('side-overlay')) {
      close();
    }
  });

  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && document.getElementById('story-drawer')) {
      close();
    }
  });

  // Graph type filters: All / Decisions / Experiments / Notes.
  document.querySelectorAll('.graph-filters').forEach(function (bar) {
    bar.querySelectorAll('.filter-tab').forEach(function (tab) {
      tab.addEventListener('click', function () {
        bar.querySelectorAll('.filter-tab').forEach(function (t) {
          t.classList.remove('on');
        });
        tab.classList.add('on');
        var filter = tab.getAttribute('data-graph-filter');
        document.querySelectorAll('.graph-node-item').forEach(function (li) {
          var type = li.getAttribute('data-graph-type');
          li.hidden = !(filter === 'all' || filter === type);
        });
      });
    });
  });
})();