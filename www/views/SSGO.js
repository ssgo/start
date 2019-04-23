var SSGOView = {
    html: 'views/SSGO.html',
    onShow: function () {
        this.data = {
            projects: [
                {name: 's', memo: '一个专为微服务定制的go语言开发框架'},
                {name: 'log', memo: '一个基于Json格式的日志框架'},
                {name: 'discover', memo: '一个客户端发现模式的服务发现'},
                {name: 'gateway', memo: '基于redis进行动态配置的网关，基于discover的h2c协议反向代理后端应用'},
                {name: 'dock', memo: '一个轻量级容器部署服务，轻松发布和管理应用'},
            ]
        }
    }
}
