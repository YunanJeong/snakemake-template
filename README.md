# snakemake-template

snakemake template, examples, test

## CMD

```sh
# 가장 자주 쓰는 실행 커맨드 (-j는 멀티코어 사용, -F는 재실행시 처음부터 빌드)
snakemake -j -F
```

```sh
# 참고용

# 기본
snakemake {대상파일(최종결과물 이름)}

# config 파일 별도 지정시
snakemake -j -C myconfig.yaml
```
