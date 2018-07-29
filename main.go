package main

import (
        "log"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"os/exec"
        "bufio"
        "strings"
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
    scanner := bufio.NewScanner(os.Stdin)
    boltDbFilepath, err := homedir.Expand("~/fast-p_cached_pdftotext_output.db")
    if err != nil {
            log.Fatal(err)
    }
    db, err := bolt.Open(boltDbFilepath, 0600, nil)
    bucketName := "fast-p_bucket_for_cached_pdftotext_output"
    if err != nil {
            log.Fatal(err)
    }
    defer db.Close()

    db.Update(func(tx *bolt.Tx) error {
        b, err := tx.CreateBucketIfNotExists([]byte(bucketName))
        b.Put([]byte("answer"), []byte("42"))
        if err != nil {
            return fmt.Errorf("create bucket: %s", err)
        }
        return nil
    })
    db.Update(func(tx *bolt.Tx) error {
        b := tx.Bucket([]byte(bucketName))
        err := b.Put([]byte("answer"), []byte("42"))
        return err
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
                fmt.Println(filepath + "\t" + content)
            } else {
                missing[hash] = filepath
            }
        }
    }
    for hash, filepath := range missing {
        cmd := exec.Command("pdftotext", "-l", "2", filepath, "-")
        out, err := cmd.CombinedOutput()
        content := string(out)
        content = strings.Replace(content, "\n", "__", -1)
        if err != nil {
            log.Println(err)
        }
        fmt.Println(filepath + "\t" + content)
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
