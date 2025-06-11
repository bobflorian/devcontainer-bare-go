package main

import (
	"bytes"
	"os"
	"strings"
	"testing"
)

func TestMain(t *testing.T) {
	// Capture stdout
	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	// Run main function
	main()

	// Restore stdout
	w.Close()
	os.Stdout = oldStdout

	// Read captured output
	var buf bytes.Buffer
	buf.ReadFrom(r)
	output := buf.String()

	// Verify expected output
	expectedStrings := []string{
		"Hello, World!",
		"=== Application Info ===",
		"Version:",
		"Build Time:",
		"Commit:",
		"=== System Info ===",
		"OS:",
		"Architecture:",
		"CPU Cores:",
		"Go Version:",
		"Hostname:",
		"Current Time:",
		"✅ Go application is running successfully!",
	}

	for _, expected := range expectedStrings {
		if !strings.Contains(output, expected) {
			t.Errorf("Expected output to contain '%s', but it didn't", expected)
		}
	}
}

func TestGetHostname(t *testing.T) {
	hostname := getHostname()

	// getHostname should return a non-empty string
	if hostname == "" {
		t.Error("Expected hostname to be non-empty")
	}

	// Verify it matches system hostname (unless there's an error)
	expectedHostname, err := os.Hostname()
	if err == nil && hostname != expectedHostname {
		t.Errorf("Expected hostname to be '%s', got '%s'", expectedHostname, hostname)
	}
}

func TestGetHostnameError(t *testing.T) {
	// Save original function
	originalFunc := hostnameFunc
	defer func() {
		hostnameFunc = originalFunc
	}()

	// Mock os.Hostname to return an error
	hostnameFunc = func() (string, error) {
		return "", os.ErrPermission
	}

	// Test that getHostname returns "unknown" on error
	hostname := getHostname()
	if hostname != "unknown" {
		t.Errorf("Expected hostname to be 'unknown' on error, got '%s'", hostname)
	}
}

func TestBuildVariables(t *testing.T) {
	// Test that build variables have default values
	tests := []struct {
		name     string
		variable string
		expected string
	}{
		{"Version", Version, "dev"},
		{"BuildTime", BuildTime, "unknown"},
		{"Commit", Commit, "unknown"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if tt.variable != tt.expected {
				t.Errorf("%s = %v, want %v", tt.name, tt.variable, tt.expected)
			}
		})
	}
}
