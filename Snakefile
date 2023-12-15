configfile: 'configsample.yaml'


# python
TMP_DIR = 'temp'

# ! python



"""
# snakemake 명령어에서 대상파일 미지정시, 첫 번째 기술된 규칙이 실행된다.
# 이를 이용하여 모든 rule이 실행되도록 하는 기본 rule을 작성할 수 있다.
# output은 적지않고, input에 최종 산출물 포맷을 명기해주면,
# 최종 결과물을 만들기 위해 다른 rule들을 재귀적으로 찾아가며 역순으로 실행한다.
"""
rule all:
    input:
        f'{TMP_DIR}/process1.done'

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
        pwd >> {output}
        """
