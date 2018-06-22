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

### attribute-map

- 사용하는 attribute들은 /install/conf/attribute-map.xml 파일에 등록되어 있어야 합니다. Shibboleth를 설치하기 전에 attribute-map을 설정하십시오.

### shibboleth2 설정 

- shibooleth2의 환경설정은 /install/conf/shibboleth2.xml 파일을 이용합니다. 
메타데이터에 요구 속성을 추가, 수정, 삭제하기 위해서는 아래 설정을 수정하십시오. 아래 ServiceName의 값을 수정하십시오.
설치과정에서 /etc/shibboleth/shibboleth2.xml 파일에 복사됩니다.

<pre>
<code>
<Handler type="MetadataGenerator" Location="/Metadata" signing="false" >
 <md:AttributeConsumingService index="1">
 <md:ServiceName xml:lang="en">Shibboleth SP Test</md:ServiceName>
 <md:RequestedAttribute FriendlyName="displayName"
 Name="urn:oid:2.16.840.1.113730.3.1.241"/>
 <md:RequestedAttribute FriendlyName="mail"
 Name="urn:oid:0.9.2342.19200300.100.1.3"/>
 <md:RequestedAttribute FriendlyName="uid"
 Name="urn:oid:0.9.2342.19200300.100.1.1"/>
 <md:RequestedAttribute FriendlyName="orgName" Name="urn:oid:2.5.4.10"/>
 <md:RequestedAttribute FriendlyName="eppn"
 Name="urn:oid:1.3.6.1.4.1.5923.1.1.1.6"/>
 <md:RequestedAttribute FriendlyName="persistent-id"
 Name="urn:oid:1.3.6.1.4.1.5923.1.1.1.10"/>
 <md:RequestedAttribute FriendlyName="schacHomeOrganization"
 Name="urn:oid:1.3.6.1.4.1.25178.1.2.9"/>
 <md:RequestedAttribute FriendlyName="unscoped-affiliation"
 Name="urn:oid:1.3.6.1.4.1.5923.1.1.1.1"/>
 </md:AttributeConsumingService>
</Handler>
</code>
</pre>


## 설치된 Service Provider의 메타데이터

https://접속주소/Shibboleth.sso/Metadata에서 메타데이터를 확인할 수 있습니다.

