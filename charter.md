Real-time conferencing sessions increasingly require end-to-end protections
that prevent intermediary servers from decrypting real-time media.  The PERC
WG developed a “double encryption” scheme for end-to-end encryption that was
deeply tied to SRTP as its underlying transport.  This entanglement has
prevented widespread deployment.

This working group will define the SFrame secure encapsulation to provide
authenticated encryption for real-time media content that is independent of
the underlying transport.  The encapsulation will provide the following
information to drive the authenticated encryption for each encryption
operation:

* Selection among multiple encryption keys in use during a real-time session

* An algorithm for forming a unique nonce within the scope of the key based
on information in the encapsulation framing

The SFrame specification will detail the specific security properties that
the encapsulation provides, and discuss their implications under common usage
scenarios / threat models.

The transport-independence of this encapsulation means that it can be applied
at a higher level than individual RTP payloads.  For example, it may be
desirable to encrypt whole frames that span multiple packets in order to
amortize the overhead from framing and authentication tags.  It may also be
desirable to encrypt units of intermediate size (e.g., H.264 NALUs or AV1
OBUs) to allow partial frames to be usable.  The working group will choose
what levels of granularity can be selected in the protocol.

An application using SFrame will need to choose several aspects of its
operation, for example:

* Selecting whether SFrame is to be used for a given media flow

* Specifying which encryption algorithm should be used

* Provisioning keys and key identifiers to endpoints

* Selecting the granularity at which SFrame encryption is applied (if
multiple options are available)

This working group, however, will not specify the signaling required to
arrange SFrame encryption.  In particular, considerations related to SIP or
SDP are out of scope.  This is because SFrame is intended to be applied as an
additional layer on top of the base levels of protection that these protocols
provide.  This working group will, however, define the guidance for how
SFrame interacts with RTP (e.g., with regard to packetization,
depacketization, and recovery algorithms) to ensure that it can be used in
environments such as WebRTC.  Other WebRTC changes such as the payload format
and metadata format will be addressed by the AVTCORE working group.

It is anticipated that several use cases of SFrame will involve its use with
keys derived from the MLS group key exchange protocol.  The working group
will define a mechanism for doing SFrame encryption using keys from MLS,
including, for example, the derivation of SFrame keys per MLS epoch and per
sender.  The availability of this mechanism for using keys from MLS does not
preclude the use of other sources of key material.
