/* Global keyboard shortcuts.
   - `c` (or `n`) opens Quick Capture
   - `/` focuses the header search input
   - `?` shows the shortcuts reference
   - `Esc` closes the story drawer and goes back from the capture classify screen
   - On the capture classify screen, `d`/`e`/`l`/`n` send the capture to a
     decision / experiment / lesson(note) straight away (via [data-kbd]).
   Shortcuts are ignored while typing in an input/textarea or editing inline. */
(function () {
  function isTyping(el) {
    if (!el) return false;
    const tag = el.tagName;
    return (
      tag === 'INPUT' ||
      tag === 'TEXTAREA' ||
      tag === 'SELECT' ||
      el.isContentEditable
    );
  }

  function shortcutsModal() {
    const existing = document.getElementById('shortcuts-modal');
    if (existing) {
      existing.remove();
      return;
    }
    const rows = [
      ['c', 'Quick capture'],
      ['/', 'Search'],
      ['d e l n', 'Route a capture to decision / experiment / lesson / note'],
      ['?', 'This reference'],
      ['esc', 'Close panel or go back'],
    ];
    const overlay = document.createElement('div');
    overlay.className = 'side-overlay';
    overlay.id = 'shortcuts-modal';

    const box = document.createElement('div');
    box.className = 'shortcuts-box';
    const h = document.createElement('h2');
    h.textContent = 'Keyboard shortcuts';
    box.appendChild(h);
    const list = document.createElement('ul');
    list.className = 'shortcuts-list';
    rows.forEach(function (row) {
      const li = document.createElement('li');
      const k = document.createElement('kbd');
      k.textContent = row[0];
      const s = document.createElement('span');
      s.textContent = row[1];
      li.appendChild(k);
      li.appendChild(s);
      list.appendChild(li);
    });
    box.appendChild(list);
    overlay.appendChild(box);

    overlay.addEventListener('click', function (e) {
      if (e.target === overlay) overlay.remove();
    });
    document.body.appendChild(overlay);
  }

  document.addEventListener('keydown', function (e) {
    if (e.ctrlKey || e.metaKey || e.altKey) return;

    if (e.key === 'Escape') {
      if (document.getElementById('shortcuts-modal')) {
        document.getElementById('shortcuts-modal').remove();
        return;
      }
      if (document.getElementById('capture-classify')) {
        window.history.back();
        return;
      }
      return;
    }

    if (isTyping(document.activeElement)) return;

    if (e.key === '?') {
      e.preventDefault();
      shortcutsModal();
      return;
    }

    if (e.key === '/') {
      e.preventDefault();
      const search = document.getElementById('search-input');
      if (search) {
        search.focus();
        search.select();
      }
      return;
    }

    const k = e.key.toLowerCase();
    const target = document.querySelector('[data-kbd="' + k + '"]');
    if (target) {
      e.preventDefault();
      target.click();
      return;
    }

    if (k === 'c' || k === 'n') {
      e.preventDefault();
      if (!document.getElementById('capture-classify')) {
        window.location.href = '/capture';
      }
    }
  });
})();