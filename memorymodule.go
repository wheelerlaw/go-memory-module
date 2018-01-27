package main

/*
#cgo CFLAGS: -IMemoryModule
#cgo LDFLAGS: MemoryModule/MemoryModule.o
#include "MemoryModule/MemoryModule.h"
*/
import "C"

import (
	"fmt"
	"io/ioutil"
	"os"
	"unsafe"
)

const SIZE int = 1024

func end(msg string) {
	fmt.Println(msg)
	os.Exit(1)
}

func check(err error, msg string) {
	if err != nil {
		end(msg)
	}
}

func main() {

	bin, err := ioutil.ReadFile(os.Args[0])
	check(err, "error reading file")

	// Convert the args passed to this program into a C array of C strings
	var cArgs []*C.char
	for _, goString := range os.Args {
		cArgs = append(cArgs, C.CString(goString))
	}

	// Load the reconstructed binary from memory
	handle := C.MemoryLoadLibraryEx(
		unsafe.Pointer(&bin[0]),                // void *data
		(C.size_t)(len(bin)),                   // size_t
		(*[0]byte)(C.MemoryDefaultAlloc),          // Alloc func ptr
		(*[0]byte)(C.MemoryDefaultFree),           // Free func ptr
		(*[0]byte)(C.MemoryDefaultLoadLibrary),    // loadLibrary func ptr
		(*[0]byte)(C.MemoryDefaultGetProcAddress), // getProcAddress func ptr
		(*[0]byte)(C.MemoryDefaultFreeLibrary),    // freeLibrary func ptr
		unsafe.Pointer(&cArgs[0]),                 // void *userdata
	)

	// Execute binary
	C.MemoryCallEntryPoint(handle)

	// Cleanup
	C.MemoryFreeLibrary(handle)

}
