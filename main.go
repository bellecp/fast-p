package main

import (
        "log"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"flag"
        "path/filepath"
	"os/exec"
        "bufio"
	"github.com/boltdb/bolt"
        "github.com/cespare/xxhash"
        "github.com/mitchellh/go-homedir"
)

func hash_file_xxhash(filePath string) (string, error) {
	var returnMD5String string
	file, err := os.Open(filePath)
	if err != nil {
		return returnMD5String, err
	}
	defer file.Close()
	hash := xxhash.New()
	if _, err := io.Copy(hash, file); err != nil {
		return returnMD5String, err
	}
	hashInBytes := hash.Sum(nil)[:]
	returnMD5String = hex.EncodeToString(hashInBytes)
	return returnMD5String, nil

}

func main() {
    version := flag.Bool("version", false, "Display program version")
    clearCache := flag.Bool("clear-cache", false, "Delete cache file located at: \n~/.cache/fast-p-pdftotext-output/fast-p_cached_pdftotext_output.db")
    flag.Parse()

    if *version != false {
        fmt.Printf("v.0.2.4 \nhttps://github.com/bellecp/fast-p\n")
        os.Exit(0)
    }

    if *clearCache !=false {
        removePath, err := homedir.Expand("~/.cache/fast-p-pdftotext-output/fast-p_cached_pdftotext_output.db")
        if err != nil {
            log.Fatal(err)
            os.Exit(1)
        }
        os.Remove(removePath)
        os.Exit(0)
    }

    // Create ~/.cache folder if does not exist
    // https://stackoverflow.com/questions/37932551/mkdir-if-not-exists-using-golang
    cachePath, err := homedir.Expand("~/.cache/fast-p-pdftotext-output/")
    os.MkdirAll(cachePath, os.ModePerm)

    // open BoltDB cache database
    scanner := bufio.NewScanner(os.Stdin)
    boltDbFilepath := filepath.Join(cachePath, "fast-p_cached_pdftotext_output.db")
    if err != nil {
            log.Fatal(err)
    }
    db, err := bolt.Open(boltDbFilepath, 0600, nil)
    bucketName := "fast-p_bucket_for_cached_pdftotext_output"
    if err != nil {
            log.Fatal(err)
    }
    defer db.Close()

    nullByte := "\u0000"

    db.Update(func(tx *bolt.Tx) error {
        b, err := tx.CreateBucketIfNotExists([]byte(bucketName))
        b.Put([]byte("answer"), []byte("42"))
        if err != nil {
            return fmt.Errorf("create bucket: %s", err)
        }
        return nil
    })

    missing := make(map[string]string)
    alreadySeen := make(map[string]bool)

    for scanner.Scan() {
        filepath := scanner.Text()
        hash, err := hash_file_xxhash(filepath)
        if alreadySeen[hash] != true {
            alreadySeen[hash] = true
            if err != nil {
                log.Println("err", hash)
            }
            var content string
            found := false
            err2 := db.View(func(tx *bolt.Tx) error {
                b := tx.Bucket([]byte(bucketName))
                v := b.Get([]byte(hash))
                if v != nil {
                    found = true
                    content = string(v)
                }
                return nil
            })
            if err2 != nil {
                log.Println(err2)
            }
            if found == true {
                fmt.Println(filepath + "\t" + content + nullByte)
            } else {
                missing[hash] = filepath
            }
        }
    }
    for hash, filepath := range missing {
        cmd := exec.Command("pdftotext", "-l", "2", filepath, "-")
        out, err := cmd.CombinedOutput()
        content := string(out)
        if err != nil {
            log.Println(err)
        }
        fmt.Println(filepath + "\t" + content + nullByte)
        db.Update(func(tx *bolt.Tx) error {
            b := tx.Bucket([]byte(bucketName))
            err := b.Put([]byte(hash), []byte(content))
            if err != nil {
                fmt.Println(err)
            }
            return nil
        })
    }
}
