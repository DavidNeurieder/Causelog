/* Global keyboard shortcuts.
   - `/` focuses the header search input
   - `n` opens Quick Capture
   - `Esc` on the post-capture classify screen goes back
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

  document.addEventListener('keydown', function (e) {
    if (e.ctrlKey || e.metaKey || e.altKey) return;
    if (isTyping(document.activeElement)) return;

    if (e.key === '/') {
      e.preventDefault();
      const search = document.getElementById('search-input');
      if (search) {
        search.focus();
        search.select();
      }
    } else if (e.key === 'n' || e.key === 'N') {
      e.preventDefault();
      window.location.href = '/capture';
    } else if (e.key === 'Escape') {
      if (document.getElementById('capture-classify')) {
        window.history.back();
      }
    }
  });
})();