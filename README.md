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
---

# Snakemake 로깅 가이드

## 1. `.snakemake/log/`에 전체로그 자동저장 (가장 권장)

- snakemake 1회 실행시, 로그파일이 1개 생성되며 파일명은 서버 시간 기준
- 단일 파일에 저장되지만, 멀티프로세싱(`-j` 옵션)시 snakemake가 Read/Write 충돌 방지를 지원 (내부적으로 python 로거가 사용됨)
- `직접조회`해도 되고, `filebeat 등으로 로그 모니터링하기에도 적당`한 구조
- `에러 발생시, 최신 로그 파일을 찾아서 별도 백업`하는 것도 괜찮은 방법 (onerror 기능, try-catch등 활용)

```sh
# 최신 로그 파일 찾기
ls -t .snakemake/log/*.snakemake.log | head -n 1
```

## 2. `log` directive (job 별 로그 저장) (약간 권장)

- 실행 directive(`shell`, `script`, ...) 내부에서 실제 **로그를 적재하는 명시적 로직이 필요**
  - `{log}` 변수 활용
  - `{log}` 경로는 자동 생성되므로 별도 `mkdir`이 필요 없음
- wildcard에 의해 여러 번 재사용되는 rule인 경우 `{log}`에도 wildcard 포함 필수
  - 동일한 파일명을 가진 job, rule이 있으면 Syntax Error 발생
  - 실사용시 wildcard 및 현재시간 기준으로 파일명을 설정해주는 것이 적절
- retry 시 기존 로그 파일을 덮어쓰며, 최종 실행 결과만 남음
  - retry하다가 끝까지 실패하면 실패로그 1개만 남고, 성공하면 성공로그 1개만 남는 식

```snakemake
rule example:
    output: "/tmp/my/output.txt"
    log: "logs/example.log"
    shell:
        "echo 'Hello' > {output} 2> {log}"
```

### 3. `exec` 활용 (비권장)

- 세션 유지(job) 동안의 모든 출력을 단일 파일에 기록 가능
- 모든 명령어에 redirection(`>>`)을 추가할 필요 없음
- 멀티프로세싱에 의한 단일파일 Read&Write **충돌방지를 snakemake가 보장하지 않음** (그래도 그럭저럭 쓸만하긴 함)
- 부분적인 로그나 stderr만 별도 추출하고 싶을 때 사용해볼 수 있는 기법
- 간단하지만 주력 사용은 비권장

```sh
# `stderr`만 별도로 저장
exec 2>> logs/stderr.log
```
