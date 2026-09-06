/* Timeline filters: All/Decisions/Experiments/Lessons/Goals tabs plus a
   "Show causal chain" toggle that isolates the decision → experiment →
   evidence → lesson thread. */
(function () {
  var tabs = document.querySelectorAll('.filter-tab');
  var chainToggle = document.getElementById('chain-toggle');
  if (!tabs.length || !chainToggle) return;

  function visibleChain() {
    return chainToggle.checked;
  }

  function apply() {
    var active = document.querySelector('.filter-tab.on');
    var filter = active ? active.getAttribute('data-filter') : 'all';
    var showChain = visibleChain();
    document.querySelectorAll('.timeline-entry').forEach(function (li) {
      var keep =
        (filter === 'all' || li.getAttribute('data-filter') === filter) &&
        (!showChain || li.getAttribute('data-chain') === 'true');
      li.hidden = !keep;
    });
    // Hide empty days and months.
    document.querySelectorAll('.timeline-month').forEach(function (month) {
      var visibleDays = 0;
      month.querySelectorAll('.timeline-day').forEach(function (day) {
        var has = Array.prototype.some.call(day.querySelectorAll('.timeline-entry'), function (li) {
          return !li.hidden;
        });
        day.hidden = !has;
        if (has) visibleDays++;
      });
      month.hidden = visibleDays === 0;
    });
  }

  tabs.forEach(function (tab) {
    tab.addEventListener('click', function () {
      tabs.forEach(function (t) { t.classList.remove('on'); });
      tab.classList.add('on');
      apply();
    });
  });
  chainToggle.addEventListener('change', apply);
})();