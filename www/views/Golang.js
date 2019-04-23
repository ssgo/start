var GolangView = {
    html: 'views/Golang.html',
    stateBinds: ['sdkByOs', 'ideByOs'],
    onShow: function () {
        actions.call('golang.list')
    }
}
