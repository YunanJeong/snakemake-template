# snakemake-template

snakemake template, examples, test

## CMD

```sh
# 가장 자주 쓰는 실행 커맨드 (-j는 멀티코어 사용, -F는 재실행시 처음부터 빌드)
snakemake -j -F

# 중간에 오류 발생하여 중단된 경우 재작업 (대용량 데이터 처리시 중간에 다양한 이슈로 실패해서 재실행이 종종 필요)
# F없이 쓰면 input,output 파일의 존재유무에 따라 중단된 부분부터 재작업된다(snakemake의 장점)
# &: 백그라운드 실행,  nohup: 터미널세션종료돼도 백그라운드작업유지
snakemake -j
```

```sh
# &: 백그라운드 실행,  nohup: 터미널세션종료돼도 백그라운드작업유지
nohup snakemake -j -F &
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

```sh
# 재작업 관련

# (특정 버전 이후)코드 변경시 -F옵션을 쓰지 않아도 처음부터 모든 데이터를 재처리함
# 최근버전에서는 input, output파일의 존재여부 외에 다음 조건을 추가적으로 고려하기 때문
# mtime(파일시간), checksum, input, params, code(코드 변경), resources 등
# 이게 옳은 방향이긴 하나, 예외사항이 필요한 경우가 있음
# --rerun-triggers 옵션을 쓰면 이 조건들중에서 일부만을 고려해서 재처리 가능

# 코드변경 후 중간지점부터 재작업이 필요할 경우 다음과 같이 실행하면 됨
snakemake --rerun-triggers mtime
# 이렇게 하면 코드변경을 무시하는 효과가 생기기 때문에 이전버전처럼 중간지점부터 재작업 가능
```
