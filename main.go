package main

import (
    "net/http"

    "github.com/dgrijalva/jwt-go"          // Known for vulnerabilities in some versions
    "github.com/gin-gonic/gin"             // Example, replace with actual vulnerable library
    "gopkg.in/yaml.v2"                     // Example, replace with actual vulnerable library
)

func main() {
    r := gin.Default()
    r.GET("/", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "message": "hello world",
        })
    })
    r.Run() // listen and serve on 0.0.0.0:8080
}
