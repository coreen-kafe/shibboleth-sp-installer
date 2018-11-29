Shibboleth SP on CentOS 6.9
===========================

- 프로덕션 서비스에 적용하지 마시고 Shibboleth 서비스제공자의 기능 검증용으로만 사용하십시오.
- CentOS 6.9에서 동작합니다. 하지만 다른 버전, 다른 리눅스 배포판에서도 유사한 방법으로 Shibboleth 서비스제공자를 구축할 수 있습니다.
- 스크립트가 아직 똑똑하지 못하므로 여러번 실행하면 오류가 발생합니다.


## 설치 전 필수 사항

- selinux와 iptables를 중지시킵니다. 설치 후 selinux와 iptables를 환경설정 하십시오.
<pre>
<code>
setenforce 0
service iptables stop
</code>
</pre>

- 웹 서비스 환경에서 HTTPS가 동작할 수 있도록 설정되어 있어야 합니다.
- NTP 설정을 통해 시간을 동기화해야 합니다.
- Discovery Service에 ID 제공자(Identity Provider)가 등록되어 있어야 합니다. 본 스크립트는 KAFE test federation 메타데이터를 이용하며 KAFE 인증서를 통해 메타데이터의 서명을 검증합니다.
- ID 제공자가 설치하고자 하는 Shibboeth 서비스제공자의 메타데이터를 저장하고 있어야 로그인이 가능합니다. 


## 설치 방법

설치 전에 환경설정(install.sh)을 하십시요.

<pre>
<code>
CONNECTOR: AJP를 이용할 경우, AJP로 설정
DOMAINNAME: FQQN(Fully Qualified Domain Name) 이나 IP 주소
DISCOVERY: EDS(Embedded Discovery Service) 또는 CDS(KAFE 제공 Central DS)
CONTACT: 서비스 관리자의 email 주소
</code>
</pre>

- 설치과정에서 SAML용 인증서를 생성합니다. 인증서 생성시 Common Name (eg, your name or your server's hostname)은 반드시 FQDN(서버에 할당된/등록된 도메인 이름)을 입력하십시오.

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

설치되는 파일들(index.php)은 login/logout 방법을 보여주기 위한 예시입니다. 프로덕션 환경에서는 보안을 고려하여 재작성하시기 바랍니다.

이용 중 의문사항은 KAFE(support@kreonet.net)으로 연락하시기 바랍니다. 

### attribute-map

- 사용하는 attribute들이 /install/conf/attribute-map.xml 파일에 등록되어 있어야 합니다. Shibboleth를 설치하기 전에 attribute-map을 설정하십시오.

### shibboleth2 설정 

스크립트 설치 전이라면 다운로드 받은 install/conf/shibboleth2.xml을 수정하시고, 스크립트 설치 후에는 시스템의 /etc/shibboleth/shibboleth2.xml을 수정해야 합니다.

- shibooleth2의 환경설정은 다운로드 받은 install/conf/shibboleth2.xml 파일을 이용합니다. 
메타데이터에 요구 속성을 추가, 수정, 삭제하기 위해서는 아래 설정을 수정하십시오. 아래 ServiceName의 값을 수정하십시오.
설치과정에서 install/conf/shibboleth2.xml이 /etc/shibboleth/shibboleth2.xml에 복사됩니다.

```XML
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
```

- 내장형 또는 중앙형 탐색서비스(discovery service)를 이용할 수 있습니다. KAFE의 탐색서비스(중앙형) URL(discoveryURL)은 https://ds.kreonet.net/kafe 입니다. 
내장형 탐색서비스의 주소는 https://[FQDN]/shibboleth-ds/index.html입니다. 설치 전에 다운로드 받은 install/conf/shibboleth2.xml에서 아래 부분을 수정하십시오.

```XML
<SSO discoveryProtocol="SAMLDS" discoveryURL="https://ds.kreonet.net/kafe">
 SAML2 SAML1
</SSO>
```
탐색서비스를 이용하지 않고 ID 제공자와 1:1로 연결할 때는 아래와 같이 ID 제공자의 entityID를 설정하십시오. 1:1로 연결되면 항상 동일한 ID 제공자로 로그인하게 됩니다.
연결한 ID 제공자의 entityID(개체 식별자)를 사전에 알고 있어야 합니다. 
KAFE에서는 검증용 ID 제공자를 제공하고 있습니다. https://testidp.kreonet.net에서 사용자 계정을 생성하거나 해당 ID 제공자의 메타데이터를 확인할 수 있습니다.

```XML
<SSO entityID="ID 제공자의 entityID" discoveryProtocol="SAMLDS" discoveryURL="https://ds.kreonet.net/kafe">
 SAML2 SAML1
</SSO>
```

## 설치된 서비스제공자의 메타데이터

https://접속주소/Shibboleth.sso/Metadata에서 메타데이터를 확인할 수 있습니다.

