# snakemake-template

snakemake template, examples, test

## CMD

```sh
# 가장 자주 쓰는 실행 커맨드 (-j는 멀티코어 사용, -F는 재실행시 처음부터 빌드)
snakemake -j -F

# 중간에 오류 발생하여 중단된 경우 재작업
# F없이 쓰면 input,output 파일의 존재유무에 따라 중단된 부분부터 재작업된다(snakemake의 장점)
# &: 백그라운드 실행,  nohup: 터미널세션종료돼도 백그라운드작업유지
nohup snakemake -j &
```

```sh
# 참고용

# 기본
snakemake {대상파일(최종결과물 이름)}

# config 파일 별도 지정 방법(file단위가 아니라 각 key를 오버라이딩하는 것임)
snakemake --configfile=myconfig.yaml

# 크론탭 등 다른 경로에서 호출시, Snakefile 경로 이동 후 사용
cd /home/ubuntu/private/snakemake-template/  && snakemake -j -F
```
