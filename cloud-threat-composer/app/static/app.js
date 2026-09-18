document.querySelectorAll("[data-open]").forEach(button => {
  button.addEventListener("click", () => document.getElementById(button.dataset.open).showModal());
});
document.querySelectorAll("[data-close]").forEach(button => {
  button.addEventListener("click", () => button.closest("dialog").close());
});
document.querySelectorAll("[data-confirm]").forEach(form => {
  form.addEventListener("submit", event => { if (!confirm(form.dataset.confirm)) event.preventDefault(); });
});

const filter = document.getElementById("severity-filter");
if (filter) filter.addEventListener("change", () => {
  document.querySelectorAll("tbody tr[data-severity]").forEach(row => {
    row.hidden = filter.value !== "all" && row.dataset.severity !== filter.value;
  });
});

const likelihood = document.getElementById("likelihood");
const impact = document.getElementById("impact");
function severity(score) { return score >= 20 ? "Critical" : score >= 12 ? "High" : score >= 6 ? "Medium" : "Low"; }
function updateRisk() {
  if (!likelihood || !impact) return;
  document.getElementById("likelihood-value").textContent = likelihood.value;
  document.getElementById("impact-value").textContent = impact.value;
  const score = Number(likelihood.value) * Number(impact.value);
  document.getElementById("risk-preview").textContent = `${score} / 25 — ${severity(score)}`;
}
if (likelihood) [likelihood, impact].forEach(input => input.addEventListener("input", updateRisk));

const component = document.getElementById("component");
const suggestion = document.getElementById("suggestion");
if (component && suggestion) {
  const library = JSON.parse(document.getElementById("threat-library").textContent);
  function loadSuggestions() {
    suggestion.innerHTML = '<option value="">Choose a suggestion (optional)</option>';
    (library[component.value] || []).forEach((item, index) => {
      const option = new Option(item.name, index); suggestion.add(option);
    });
  }
  component.addEventListener("change", loadSuggestions);
  suggestion.addEventListener("change", () => {
    if (suggestion.value === "") return;
    const item = library[component.value][Number(suggestion.value)];
    document.getElementById("threat-name").value = item.name;
    document.getElementById("threat-description").value = item.description;
    document.getElementById("stride-category").value = item.stride;
  });
  loadSuggestions();
}
