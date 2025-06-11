// Package main implements a simple Go application with system information display.
package main

import (
	"fmt"
	"os"
	"runtime"
	"time"
)

var (
	// Version represents the application version, set during build time.
	Version = "dev"
	// BuildTime represents when the application was built, set during build time.
	BuildTime = "unknown"
	// Commit represents the git commit hash, set during build time.
	Commit = "unknown"
)

func main() {
	fmt.Println("Hello, World!")
	fmt.Println()

	fmt.Println("=== Application Info ===")
	fmt.Printf("Version:     %s\n", Version)
	fmt.Printf("Build Time:  %s\n", BuildTime)
	fmt.Printf("Commit:      %s\n", Commit)
	fmt.Println()

	fmt.Println("=== System Info ===")
	fmt.Printf("OS:          %s\n", runtime.GOOS)
	fmt.Printf("Architecture: %s\n", runtime.GOARCH)
	fmt.Printf("CPU Cores:   %d\n", runtime.NumCPU())
	fmt.Printf("Go Version:  %s\n", runtime.Version())
	fmt.Printf("Hostname:    %s\n", getHostname())
	fmt.Printf("Current Time: %s\n", time.Now().Format("2006-01-02 15:04:05"))
	fmt.Println()

	fmt.Println("✅ Go application is running successfully!")
}

// hostnameFunc is a variable to allow testing of error paths.
var hostnameFunc = os.Hostname

func getHostname() string {
	hostname, err := hostnameFunc()
	if err != nil {
		return "unknown"
	}
	return hostname
}
