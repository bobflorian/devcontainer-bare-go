package main

import (
	"fmt"
	"log"
	"net/http"
	"runtime"
)

var (
	Version   = "dev"
	BuildTime = "unknown"
	Commit    = "unknown"
)

func main() {
	log.Printf("Starting application v%s (built: %s, commit: %s)", Version, BuildTime, Commit)
	log.Printf("Running on %s/%s", runtime.GOOS, runtime.GOARCH)

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello from Go! Running on %s/%s\n", runtime.GOOS, runtime.GOARCH)
		fmt.Fprintf(w, "Version: %s\n", Version)
		fmt.Fprintf(w, "Build Time: %s\n", BuildTime)
		fmt.Fprintf(w, "Commit: %s\n", Commit)
	})

	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprint(w, "OK")
	})

	port := ":8080"
	log.Printf("Server starting on port %s", port)
	if err := http.ListenAndServe(port, nil); err != nil {
		log.Fatal(err)
	}
}