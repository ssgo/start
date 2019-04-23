package service

import (
	"fmt"
	"github.com/ssgo/config"
	"github.com/ssgo/httpclient"
	"github.com/ssgo/log"
	"github.com/ssgo/s"
	"github.com/ssgo/standard"
	"github.com/ssgo/u"
	"io/ioutil"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"
)

var conf = struct {
	Production bool
}{}

type sdkInfo struct {
	Os      string
	Bits    string
	Version string
	File    string
}

type ideInfo struct {
	Os      string
	Version string
	File    string
}

func init() {
	_ = config.LoadConfig("start", &conf)
}

func getGolangList(request *http.Request) (out struct {
	Sdk     []sdkInfo
	Ide     []ideInfo
	BaseUrl string
}) {
	out.Sdk = getSDKList()
	out.Ide = getIDEList()
	if conf.Production {
		out.BaseUrl = fmt.Sprint(u.StringIf(request.TLS == nil, "http", "https"), "://", request.Header.Get(standard.DiscoverHeaderHost), "/")
	}else{
		out.BaseUrl = fmt.Sprint(u.StringIf(request.TLS == nil, "http", "https"), "://", s.GetServerAddr(), "/")
	}
	return
}

func getSDKList() []sdkInfo {
	list := make([]sdkInfo, 0)
	lines := make([]string, 0)
	if conf.Production {
		if !u.FileExists(os.TempDir() + "gosdk.list") {
			makeCachedSDKList()
		}
		_ = u.Load(os.TempDir()+"gosdk.list", &lines)
	} else {
		files, err := ioutil.ReadDir("./sdk")
		if err != nil {
			log.Error("Start", "error", err)
			return list
		}
		for _, file := range files {
			lines = append(lines, file.Name())
		}
	}
	re, _ := regexp.Compile("^go(\\d+\\.\\d+)\\.(\\w+)-(\\w+)\\..*$")
	for _, line := range lines {
		matchs := re.FindStringSubmatch(line)
		if len(matchs) == 4 {
			if matchs[2] == "darwin" {
				matchs[2] = "Mac"
			} else {
				buf := []byte(matchs[2])
				buf[0] -= 32
				matchs[2] = string(buf)
			}
			list = append(list, sdkInfo{Os: matchs[2], Bits: matchs[3], Version: matchs[1], File: line})
		}
	}
	return list
}

func makeCachedSDKList() {
	listResult := httpclient.GetClient(10 * time.Second).Get("http://ssgo.isstar.com/gosdk/list").String()
	lines := strings.Split(strings.TrimSpace(listResult), "\n")
	u.Save(os.TempDir()+"gosdk.list", &lines)
}

func makeCachedIDEList() {
	listResult := httpclient.GetClient(10 * time.Second).Get("http://ssgo.isstar.com/goide/list").String()
	lines := strings.Split(strings.TrimSpace(listResult), "\n")
	u.Save(os.TempDir()+"goide.list", &lines)
}

func getIDEList() []ideInfo {
	list := make([]ideInfo, 0)
	lines := make([]string, 0)
	if conf.Production {
		if !u.FileExists(os.TempDir() + "goide.list") {
			makeCachedIDEList()
		}
		_ = u.Load(os.TempDir()+"goide.list", &lines)
	} else {
		files, err := ioutil.ReadDir("./ide")
		if err != nil {
			log.Error("Start", "error", err)
			return list
		}
		for _, file := range files {
			lines = append(lines, file.Name())
		}
	}
	re, _ := regexp.Compile("^goland\\-(\\d+\\.\\d+)\\.(\\w+)")
	for _, line := range lines {
		matchs := re.FindStringSubmatch(line)
		if len(matchs) == 3 {
			list = append(list, ideInfo{Os: u.StringIf(matchs[2] == "dmg", "Mac", "Windows"), Version: matchs[1], File: line})
		}
	}
	return list
}

func getSDKInstaller(in struct{ Index int }, request *http.Request) string {
	list := getSDKList()
	if in.Index >= 0 && in.Index < len(list) {
		item := list[in.Index]

		installCmd := ""
		if strings.HasSuffix(item.File, ".tar.gz") {
			installCmd = fmt.Sprint(
				"tar -C /usr/local -zxf /tmp/", item.File, "\n",
				"echo \"\" >> /etc/profile\n",
				"echo \"export GOROOT=/usr/local/go\" >> /etc/profile\n",
				"echo \"export PATH=$PATH:/usr/local/go/bin\" >> /etc/profile\n",
				"echo \"export GOPROXY=https://goproxy.io\" >> /etc/profile\n",
				"source /etc/profile\n",
			)
		} else if strings.HasSuffix(item.File, ".dmg") {
			installCmd = fmt.Sprint(
				"open /tmp/", item.File, "\n",
				"echo \"export GOPROXY=https://goproxy.io\" >> ~/.bash_profile\n",
				"source ~/.bash_profile\n",
			)
		}

		baseUrl := u.StringIf(conf.Production, "http://ssgo.isstar.com/gosdk/", "http://"+s.GetServerAddr()+"/sdk/")
		if strings.HasSuffix(item.File, ".msi") {
			return fmt.Sprint(
				"echo 即将开始安装：", item.File, "\n",
				"curl -o /tmp/", item.File, " ", baseUrl, item.File, "\n",
				"/tmp/", item.File, "\n",
			)
		} else {
			return fmt.Sprint(
				"echo 即将开始安装：", item.File, "\n",
				"curl -o /tmp/", item.File, " ", baseUrl, item.File, "\n",
				installCmd,
			)
		}
	}
	return "echo 没有找到安装对象"
}
