configfile: 'configsample.yaml'

# python
TMP_DIR = config['tmp_dir']
JOBS = config['jobs']
# ! python

"""
# snakemake 명령어에서 target파일 미지정시, 첫 번째 기술된 rule이 실행된다.
# 이를 이용하여 모든 rule 실행을 유도하는 rule(all)을 작성할 수 있다.
# rule(all)의 input에 최종 산출물 포맷을 명시해주면,
# 최종 결과물을 만들기 위해 다른 rule들을 재귀적으로 찾아가며 역순으로 실행된다.
# rule(all)에서 output과 실행파트(shell)은 안적어도 무방하다. 전부 완료되었다는 로그를 남기는 등 마무리작업에 사용할 수 있다.
"""
rule all:
    input:
        f'{TMP_DIR}/multi_process.done'
    output:
        f'{TMP_DIR}/all_clear.done'
    shell:
        """
        touch {output}
        # rm -rf temp # => 단, 마지막에 파이프라인 input, output 으로 사용되는 파일들을 정리하면 안된다. 에러 뜸.
        """
rule rule0:
    output:
        f'{TMP_DIR}/rule0.done'
    shell:
        """
        echo 'rule0' > {output}
        """

# input, output, log 등의 directives에서 절대, 상대경로 둘 다 가능
# shell에서 {input}, {output}, {log} 라는 템플릿 변수로 호출가능
rule rule1:
    # # input파일 명시
    # - 기술된 input 파일이 존재해야 rule이 실행됨(실행조건)    
    input:  f'{TMP_DIR}/rule0.done'

    # # output파일 명시
    # - 아래 실행directive(shell,script,...)에서 실제 output생성로직 필요.
    # - 단, {output}에 "포함된" 경로는 자동생성되므로 별도 mkdir이 필요없음
    output: f'{TMP_DIR}/rule1_{{job}}.done'

    # # 작업실패시 해당 rule만 즉시 retry (snakemake>=7.7.0부터 가능)
    retries: 3
        
    # # rule 로그파일 명시
    # - 아래 실행directive(shell,script,...)에서 실제 log생성로직 필요.
    # - 단, {log}에 "포함된" 경로는 자동생성되므로 별도 mkdir이 필요없음
    # # 다른 job과 파일명 중복시 Syntax Error
    # - 다른 rule과 중복X
    # - wildcard로 멀티프로세싱할 때 로그파일명에도 wildcard 필요
    # - retry시 이전 try의 파일을 덮어씀.
    #   - retry하다가 끝까지 실패하면 실패로그 1개만 남고, 성공하면 성공로그 1개만 남는 식.
    # # 단일 로그파일(logs/snakemake.log) 사용시
    # - log directives 대신 별도 로그파일 관리필요. append redirection(>>)하면 됨
    # - 단, 이 때 멀티프로세싱에 의한 단일파일 Read&Write 충돌방지를 snakemake가 보장하는지는 미확인
    log: "logs/rule_targetdate_{job}.log" 
     
    shell:
        """
        # rulelog 테스트
        echo 'rulelog' >> {log}
        
        # 세션(rule)유지동안 error 발생시 로그저장
        # exec를 통해 세션 유지동안의 모든 출력을 관리가능. 모든 명령어에 redirection 처리할 필요가 없어짐
        exec 2>> logs/snakemake.log

        # 에러유발 테스트
        # 참고) 에러발생시 snakemake가 즉시 중단되므로, 다음 쉘 명령어가 실행되지 않음
        # ddddd

        touch rule1.done && mv rule1.done {output}
        """
        
rule multi_process:
    input:
        expand(TMP_DIR + '/rule1_{job}.done', job=JOBS)
    output:
        f'{TMP_DIR}/multi_process.done'
    shell:
        """
        touch {output}
        """
onsuccess:
    print('snakemake success')
    shell("echo [$(date)] 'Snakemake Success'  >> logs/snakemake.log") 
onerror:
    print("snakemake failed")
    shell("echo [$(date)] 'Snakemake Failed:'  >> logs/snakemake.log") 


# os.system("ls temp")
# => 맨 마지막에 파이썬 코드를 적어도 rule 진입전에 실행된다. 마무리작업은 별도로 처리해줘야 할 수 도 있다.