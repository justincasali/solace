serverless cross-region dynamodb to s3 backup restore tool

```
message = {

    action: "backup" | "restore"
    
    total-segments: integer < max-segments
    
    table-region: aws region string
    
    table-name: string
    
    bucket-region: aws region string
    
    bucket-name: string
    
    bucket-prefix: string
    
}
```
