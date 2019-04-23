package service

import (
	"github.com/ssgo/s"
)

func Registers() {
	s.Static("/sdk/", "sdk/")
	s.Static("/ide/", "ide/")
	s.Static("/", "www/")
	s.Restful(0, "GET", "/golang/list", getGolangList)
	s.Restful(0, "GET", "/i/s{index}", getSDKInstaller)
}
