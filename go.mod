module example/vulnerable-app

go 1.16

require (
    github.com/dgrijalva/jwt-go v3.2.0+incompatible // Vulnerable version as an example
    github.com/gin-gonic/gin v1.6.3                 // Example, replace with actual vulnerable version
    gopkg.in/yaml.v2 v2.2.8                         // Example, replace with actual vulnerable version
)
