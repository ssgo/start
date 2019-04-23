var GolangAction = {
    'list': function (ctx) {
        ctx.http.get('/golang/list').then(function (data) {
            let sdkByOs = {}
            for (let i in data.sdk) {
                let sdk = data.sdk[i]
                if (!sdk.os) continue
                if (!sdkByOs[sdk.os]) sdkByOs[sdk.os] = []
                sdkByOs[sdk.os].push(sdk)
                sdk.cmd = 'curl ' + data.baseUrl + 'i/s' + i + ' | sh'
            }
            let ideByOs = {}
            for (let i in data.ide) {
                let ide = data.ide[i]
                if (!ide.os) continue
                if (!ideByOs[ide.os]) ideByOs[ide.os] = []
                ideByOs[ide.os].push(ide)
            }
            ctx.states.set({sdkByOs, ideByOs})
            // L({sdkByOs, ideByOs})
            ctx.resolve()
        }).catch(ctx.reject)
    },
}
