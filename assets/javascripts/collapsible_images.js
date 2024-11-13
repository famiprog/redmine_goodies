function expandAll(event) {
    localStorage.setItem("isCollapsed", "false");
    const element = document.querySelector("#main");
    const detailsElements = element.querySelectorAll(".collapsible-img");
    detailsElements.forEach(function(detailsElement) {
        if (!detailsElement.hasAttribute("open")) {
            detailsElement.setAttribute("open", true);
        }
    });
    addBackgroundToCollapsibleImage(event.target?.parentElement.parentElement);
}

function collapseAll(event) {
    localStorage.setItem("isCollapsed", "true");
    const element = document.querySelector("#main");
    const detailsElements = element.querySelectorAll(".collapsible-img");
    detailsElements.forEach(function(detailsElement) {
        if (detailsElement.hasAttribute("open")) {
            detailsElement.removeAttribute("open");
        }
    });
    addBackgroundToCollapsibleImage(event.target?.parentElement.parentElement);
}

function getIsCollapsedValueFromLocalStorage() {
    const isCollapsed = localStorage.getItem("isCollapsed");
    isCollapsed === "true" ? collapseAll("#main") : expandAll("#main");
}

function addBackgroundToCollapsibleImage(detailsElement) {
    if (!detailsElement) { return; }
    detailsElement.classList.add("collapsible-highlighted");
    if (!isElementInViewport(detailsElement)) {
        setTimeout(() => {
            detailsElement.scrollIntoView({ behavior: "smooth", block: "start" });
        }, 500);
    }
    setTimeout(() => {
        detailsElement.classList.remove("collapsible-highlighted");
    }, 2000);
}

function isElementInViewport(element) {
    const rect = element.getBoundingClientRect();
    return (
        rect.top >= 0 && rect.left >= 0 &&
        rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
        rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
}