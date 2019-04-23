// 选择器
window.$ = function (selector) {
    if (!selector) return document.body
    return document.querySelector(selector)
}
window.$$ = function (selector) {
    if (!selector) return [document.body]
    return document.querySelectorAll(selector)
}
window.L = function (obj) {
    console.log(obj)
}
window.CP = function (data) {
    return JSON.parse(JSON.stringify(data))
}

var states = new svcState.State('binds')
var http = new svcWeb.Http('//' + location.host)
var route = new svcWeb.Route(states)
var tpl = new svcWeb.Tpl()
var actions = new svcAction.Action({
    states: states,
    route: route,
    http: http
})

actions.register('golang', GolangAction)

// 设置根路由Root
route.Root = {
    getSubView: function (subName) {
        switch (subName) {
            case 'ssgo':
                return SSGOView
            case 'golang':
                return GolangView
            case 'tool':
                return ToolView
        }
    }
}

function setNavStatus(target) {
    for (let li of $$('.navbar-nav > li')) {
        li.className = ''
    }
    if(!target) target = $('.navbar-nav > li')
    target.className = 'active'
}

route.bindHash()
route.bind('*', route.Root)

window.addEventListener('load', function () {
    let path = location.hash ? location.hash.substring(1) : '/ssgo'
    route.go(path)
    setNavStatus($$('.navbar-nav > li')[{'/ssgo':0,'/golang':1,'/tool':2}[path]])
})
