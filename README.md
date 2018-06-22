Shibboleth SP on CentOS 6.9
===========================

- 프로덕션 서비스에 적용하지 마시고 Shibboleth Service Provider의 검증용으로만 사용하십시오.
- CentOS 6.9에서 동작합니다. 하지만 다른 버전, 다른 리눅스 배포판에서도 유사한 방법으로 Shibboleth Service Provider를 구축할 수 있습니다.
- 스크립트가 아직 똑똑하지 못하므로 여러번 실행하면 오류가 발생합니다.


## 설치 전 필수 사항

- selinux와 iptables를 중지시킵니다. 설치 후 selinux와 iptables를 환경설정 하십시오.
<pre>
<code>
setenforce 0
service iptables stop
</code>
</pre>

- HTTPS가 동작하도록 미리 환경설정이 되어 있어야 합니다.
- NTP 설정을 통해 시간을 동기화해야 합니다.
- Discovery Service에 Identity Provider가 등록되어 있어야 합니다. 본 스크립트는 KAFE test federation 메타데이터를 이용하며 KAFE 인증서를 통해 서명을 검증합니다.
- 하나 이상의 Identity Provider가 설치하고자 하는 Service Provider의 메타데이터를 저장하고 있어야 합니다.


## 설치 방법

설치전에 환경설정(install.sh)을 하십시요. 

<pre>
<code>
CONNECTOR: AJP를 이용할 경우, AJP로 설정
DOMAINNAME: FQQN(Fully Qualified Domain Name) 이나 IP 주소
DISCOVERY: EDS(Embedded Discovery Service) 또는 KAFE 제공 CDS(Central DS)
</code>
</pre>

<pre>
<code>
cd shibboleth-sp-installer
sh install.sh
</code>
</pre>


## 이용 방법

- secure 디렉토리가 잠금설정 되어 있습니다. https://접속주소/secure/로 접속하면 로그인 절차가 시작됩니다.
- https://접속주소/로 접근하면 로그인이 가능합니다.
- https://접속주소/secure에서 로그아웃이 가능합니다.


## 설치된 Service Provider의 메타데이터

https://접속주소/Shibboleth.sso/Metadata에서 메타데이터를 확인할 수 있습니다.

