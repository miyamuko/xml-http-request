=begin

=== 2008-07-12 / 1.2.1

xml-http-request 1.2.1 �����[�X!

: �V�K�@�\

    * �Ȃ�

: ��݊����܂ޕύX�_

    * �Ȃ�

: �o�O�C��

    * �Ȃ�

: ���̑�

    * ���C�Z���X�t�@�C���𓯍�


=== 2008-03-30 / 1.2.0

xml-http-request 1.2.0 �����[�X!

: �V�K�@�\

    * �e���N�G�X�g���\�b�h�� basic-auth ������ǉ����܂����B

      Basic �F�؂̂��߂̃��[�U���ƃp�X���[�h���w�肵�܂��B

        (xhr-get "http://foo.com" :basic-auth (xhr-credential "user" "password"))

: ��݊����܂ޕύX�_

    * basic-auth �������w�肹���� Basic �F�؂��K�v�� URI �ɐڑ������ꍇ
      �F�؏�����͂���_�C�A���O���\������܂��B

      1.0.0 �` 1.1.1 �ł͔F�؃_�C�A���O�͕\������܂���B
      0.1 �ł͕\������܂��B

: �o�O�C��

    * �ڑ����� URL �� userinfo �ɔF�؏����w�肵�Ă��������������C��
      (��������ɂ���)

        (xhr-get "http://user:password@foo.com")

      �� basic-auth �������w�肵���ꍇ�� URL �� userinfo �͖�������܂��B


=== 2008-03-03 / 1.1.1 / �ЂȂ܂�

xml-http-request 1.1.1 �����[�X!

: �V�K�@�\

    * post �ȊO�̃��N�G�X�g�֐��� query �� encoding �L�[���[�h������ǉ��B
      query string �����X�g�Ŏw��ł��܂��B

: ��݊����܂ޕύX�_

    * �Ȃ�

: �o�O�C��

    * xml-http-request 1.1.0 �ŗ��p���� XMLHttpRequest �I�u�W�F�N�g��
      Msxml2.XMLHTTP.6.0 �ɂ�������X�V���Ă������A
      xyzzy �Ƃ̑g�ݍ��킹�ɖ�肪�������̂� Msxml2.XMLHTTP �ɖ߂����B


=== 2008-02-23 / 1.1.0

xml-http-request 1.1.0 �����[�X!

: �V�K�@�\

    * �e���N�G�X�g�֐��� nomsg �L�[���[�h������ǉ��B

      * nomsg �� non-nil ���w�肷��ƃ��b�Z�[�W���o�͂��܂���B

    * xhr-future-value �� no-redraw �� sleep �L�[���[�h������ǉ��B

      * no-redraw �� non-nil ���w�肷��Ƒ҂����킹���ɉ�ʂ̍ĕ`����s���܂���B
      * sleep �� non-nil ���w�肷��Ƒ҂����킹���Ɋ��荞�݂ł��Ȃ��悤�ɂ��܂��B

: ��݊����܂ޕύX�_

    * �Ȃ�

: �o�O�C��

    * �Ȃ�


=== 2008-02-11 / 1.0.1 / �����L�O�̓�

xml-http-request 1.0.1 �����[�X!

: �V�K�@�\

    * (xhr-abort): ���ɒʐM���I�����Ă����牽������ nil ��Ԃ��A
      �ʐM�𒆒f�����Ȃ� t ��Ԃ��悤�ɂ����B

: ��݊����܂ޕύX�_

    * (xhr-xxx-async): �߂�l�� cancel-ticket ��Ԃ��悤�ɂ����B
      cancel-ticket �� xhr-abort �Ɏw�肵�ĒʐM�𒆒f�\�B

    * (http-get, http-post): �񓯊����M���� oledata ��Ԃ��B

    * xhr-xxx-future �Ɏw�肵�� key �֐��̒��ŃG���[�����������ꍇ�A
      xhr-future-value �������_�ŃG���[��ʒm�B

: �o�O�C��

    * �Ȃ�


=== 2008-02-11 / 1.0.0 / �����L�O�̓�

xml-http-request 1.0.0 �����[�X!

: �V�K�@�\

    * ���j���[�A��

    * Future �p�^�[���̃T�|�[�g

    * �C�x���g�n���h���̃}�N����

: ��݊����܂ޕύX�_

    * xml-http-request 0.1 �Ƃ̌݊��w��p�ӂ��Ă���̂Ŋ�{�I�ɂ͓����͂��ł��B

: �o�O�C��

    * ���Ԃ�Ȃ�


=== 2006-06-13 / 0.1

xml-http-request 0.1 �����[�X!

=end
