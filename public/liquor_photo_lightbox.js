// Full-size storefront photo overlay — one delegated click handler so open + bubble don't instantly close.
;(function () {
  const dialogSelector = "#liquor-photo-lightbox"
  let lastOpener = null

  function openFrom(opener, dialog) {
    const src = opener.getAttribute("data-photo-lightbox-src")
    if (!src) return

    lastOpener = opener

    const name = opener.getAttribute("data-photo-lightbox-name") || ""
    const img = dialog.querySelector("[data-photo-lightbox-image]")
    const title = dialog.querySelector("#liquor-photo-lightbox-title")

    if (img) {
      img.src = src
      img.alt = name ? `Full-size photo — ${name}` : "Liquor bottle photo full size."
    }

    if (title) title.textContent = name || ""

    if (typeof dialog.showModal !== "function") return

    dialog.showModal()

    queueMicrotask(function () {
      const closeBtn = dialog.querySelector("[data-photo-lightbox-close]")
      if (closeBtn) closeBtn.focus()
    })
  }

  document.addEventListener("click", function (event) {
    const opener = event.target.closest("[data-photo-lightbox-src]")
    const dialog = document.querySelector(dialogSelector)

    if (opener) {
      event.preventDefault()
      if (dialog) openFrom(opener, dialog)
      return
    }

    if (!dialog || !dialog.open) return

    if (event.target.closest("[data-photo-lightbox-close]")) {
      event.preventDefault()
      dialog.close()
      return
    }

    if (!event.target.closest("[data-photo-lightbox-panel]")) dialog.close()
  })

  ;(function wire(dialog) {
    if (!dialog) return

    dialog.addEventListener("close", function () {
      lastOpener?.focus?.()
      lastOpener = null

      const img = dialog.querySelector("[data-photo-lightbox-image]")
      if (img) {
        img.removeAttribute("src")
        img.alt = ""
      }
    })
  })(document.querySelector(dialogSelector))
})()
