/* inst/app/www/app.js
 *
 * WHERE THIS FILE LIVES:
 *   inst/app/www/ is Shiny's static-file directory.
 *   Any file placed here is served automatically at the root URL path.
 *   Load it in ui.R with:
 *     tags$head(tags$script(src = "app.js"))
 *
 * jQuery is loaded by Shiny/Bootstrap before this file runs,
 * so $(...) is always available here.
 */

/* ── Collapsible sidebar panels ─────────────────────────────────────────────
 *
 * Each .hd-toggle button carries a data-target attribute that points to
 * the id of its collapsible sibling div, e.g. data-target="#panel-spec".
 * Clicking toggles the "open" CSS class on both the button (rotates the
 * arrow via CSS transform) and the target div (sets display:block).
 *
 * This is 100% client-side — zero server round-trips.
 * The original code did the same thing with an inline script in ui.R.
 * Moving it here keeps ui.R free of JavaScript strings.
 */
$(document).on("click", ".hd-toggle", function () {
  var target = $(this).data("target");
  $(this).toggleClass("open");
  $(target).toggleClass("open");
});

/* ── Auto-open Spec panel after upload ──────────────────────────────────────
 *
 * When a file is uploaded and column names are populated, the server calls
 * updateSelectInput("x", choices = ...).  Shiny fires a "shiny:inputchanged"
 * event for every input that gets updated.  We listen for the first "x"
 * change and open the Spec panel automatically so the user does not have
 * to click the toggle after uploading.
 *
 * The panel is only ever opened by this handler, never closed — the user
 * can still collapse it manually afterward.
 *
 * Why "x"?  It is always the first updateSelectInput() call in the server,
 * so it reliably signals that all four column dropdowns have been populated.
 */
$(document).on("shiny:inputchanged", function (e) {
  if (e.name === "data-x") {   /* namespaced as "data-x" by the data module */
    var $panel  = $("[id$='panel-spec']");   /* ends-with selector for ns() id */
    var $toggle = $("[data-target$='panel-spec']");
    if (!$panel.hasClass("open")) {
      $panel.addClass("open");
      $toggle.addClass("open");
    }
  }
});
