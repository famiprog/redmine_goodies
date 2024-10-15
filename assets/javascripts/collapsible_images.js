function expandAll(containerElement) {
    localStorage.setItem("isCollapsed", "false");
    const element = document.querySelector(containerElement);
    const detailsElements = element.querySelectorAll(".collapsible-img");
    detailsElements.forEach(function(detailsElement) {
        if (!detailsElement.hasAttribute("open")) {
            detailsElement.setAttribute("open", true);
        }
    });
}

function collapseAll(containerElement) {
    localStorage.setItem("isCollapsed", "true");
    const element = document.querySelector(containerElement);
    const detailsElements = element.querySelectorAll(".collapsible-img");
    detailsElements.forEach(function(detailsElement) {
        if (detailsElement.hasAttribute("open")) {
            detailsElement.removeAttribute("open");
        }
    });
}

function getIsCollapsedValueFromLocalStorage() {
    const isCollapsed = localStorage.getItem("isCollapsed");
    isCollapsed === "true" ? collapseAll("#main") : expandAll("#main");
}
