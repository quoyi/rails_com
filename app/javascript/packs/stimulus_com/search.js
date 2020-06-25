import { Controller } from 'stimulus'

class SearchController extends Controller {
  static targets = ['input', 'label']

  connect() {
    console.log('Search Controller works!')
  }

  focus() {
    this.element.classList.add('weui-search-bar_focusing')
    this.inputTarget.focus()
  }

  doSearch(element) {
    let ele = element.currentTarget
    alert(ele.value)
    if (ele.value.length) {
      alert(ele.value)
    }
  }

  clear() {
    Turbolinks.visit(location.pathname, { action: 'replace' })
    this.inputTarget.value = ''
    this.inputTarget.focus()
  }

  cancel() {
    this.element.classList.remove('weui-search-bar_focusing')
    this.inputTarget.blur()
  }

}

application.register('search', SearchController)
