configfile: 'configsample.yaml'


# python
TMP_DIR = config['tmp_dir']

# ! python



"""
# snakemake 명령어에서 대상파일 미지정시, 첫 번째 기술된 규칙이 실행된다.
# 이를 이용하여 모든 rule이 실행되도록 하는 기본 rule을 작성할 수 있다.
# input에 최종 산출물 포맷을 명기해주면,
# 최종 결과물을 만들기 위해 다른 rule들을 재귀적으로 찾아가며 역순으로 실행한다.
# output과 실행파트(shell)은 안적어도 무방하다. 전부 완료되었다는 로그를 남기는 등 마무리작업에 사용할 수 있다.
"""
rule all:
    input:
        f'{TMP_DIR}/process1.done'
    output:
        f'{TMP_DIR}/all_clear.done'
    shell:
        """
        touch {output}
        # rm -rf temp # => 단, 마지막에 파이프라인 input, output 으로 사용되는 파일들을 정리하면 안된다. 에러 뜸.
        """
rule process0:
    output:
        f'{TMP_DIR}/process0.done'
    shell:
        """
        echo 'process0' > {output}
        """
rule process1:
    # input, output에는 절대, 상대경로 모두 가능.
    input:
        # input 데이터 명시
        # 기술된 input 파일이 존재해야 rule이 실행됨(실행조건)
        f'{TMP_DIR}/process0.done'
    output:
        # output 데이터 명시
        # 이것만으로 output 파일이 생성되지는 않음
        # 아래 실행파트(shell,script,...)에 실제 결과물 생성로직이 있어야 함
        # 단, output에 "포함된" 경로는 snakemake가 자동생성해주기 때문에 별도 mkdir이 필요없음
        f'{TMP_DIR}/process1.done'
    shell:
        """
        touch process1.done
        mv process1.done {output}
        # pwd >> {output}
        """



# os.system("ls temp")
# => 맨 마지막에 파이썬 코드를 적어도 rule 진입전에 실행된다. 마무리작업은 별도로 처리해줘야 할 수 도 있다.