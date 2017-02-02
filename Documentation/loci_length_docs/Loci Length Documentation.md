# Loci lengths

|Loci  | Exact length stored in db | Length of full gene   | Query full gene? (T/F) | Query partial genes?(T/F) | Notes                                                                                |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|penA  | 732                       | 1752                  | T                      | T                         |                                                                                      |
|mtrR  | 708                       | 708                   | T                      | T                         |                                                                                      |
|porB  | 60                        | 1047                  | T (full) / T (ngmast)  | T                         |                                                                                      |
|ponA  | 75                        | 1261                  | T                      | T                         |                                                                                      |
|gyrA  | 264                       | 420                   | T                      | T                         |                                                                                      |
|parC  | 332                       | 2304                  | T                      | T                         |                                                                                      |
|23S   | 567                       | 2904                  | T                      | T                         |                                                                                      |
```

```
|Loci | len db range | len in tbl_Loci | length full        | common query len |
|------------------------------------------------------------------------------|
|penA | 726-732      | 732             | 1746-1752          | 732              |
|mtrR | 698-708      | 708             | 698-708            | 698-708          |
|porB | 60           | 60              | 1047 (490 NG-MAST) | 490              |
|ponA | 75           | 75              | 1261               | 1261             |
|gyrA | 264          | 264             | 420                | 264/420          |
|parC | 332          | 332             | 2304               | 332/2304         |
|23S  | 567          | 567             | 2904               | 714              |
```


***Offset is set to 50 because the total length of primers is less than or equal to 50 bp. Offset is used in **ValidateAllele.pm**

