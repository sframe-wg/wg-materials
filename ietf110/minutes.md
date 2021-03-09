# SFrame Working Group

The SFrame Working Group met at IETF 110.


## Meeting Details

Tuesday Session II (15:30-16:30 UTC+1, 14:30-15:30 UTC)
Chairs: Bobo Bose-Kolanu, Martin Thomson

* [Minutes](https://codimd.ietf.org/notes-ietf-110-sframe)
* [Chat](xmpp:sframe@jabber.ietf.org?join) <- defunct technology!
* [Real-time Video and Audio](https://meetings.conf.meetecho.com/ietf110/?group=sframe&short=&item=1)
* [Calendar](https://datatracker.ietf.org/meeting/110/session/28715.ics)
* [Materials](https://github.com/sframe-wg/wg-materials)
* [Note Well](https://www.ietf.org/about/note-well/)

## Agenda

### [welcome, administrivia, agenda](https://sframe-wg.github.io/wg-materials/ietf110/chair.pdf)
  * 10 min   Martin Thomson / Bobo Bose-Kolanu
  * Note well
  * Agenda bash
  * Status update; no real list activity, no adoption of new drafts
  * Minutes: Watson Ladd (and friends)

### [Use cases, scope](https://sframe-wg.github.io/wg-materials/ietf110/scope.pdf)
  * 10 min   Tim Panton
  * 4,000 foot view
  * Based on implementation experience
  * Single usecase for selective forwarding units: protect your data from your service provider.
  * SFU does bandwidth/resolution impedence match
  * SFU: what can I drop?
  * Scope: As little as possible
  * Hurry! It's shipping. Jitsi is doing it
  * Document and avoid the footcanons. Wonderful ones.
  * Describe what unencrypted SFU can see, what to drop, when, and what it can cache
  * Richard: Webex shipping, and it's incompatible!
  * Jonathan: more footcannons than anticipated. Accidentally encrypting and not encrypting both bad. Going to be a hard problem in general with good interop as opposed to specific codec with lots of info.
  * Tim: Yup, huge pitfalls. Not abstracting we already fell into.
  * If you don't drop or do drop incorrectly doesn't matter much: over UDP
  * Overemphesis on precision
  * Jonathan: True, does imply thing about encoders. Assumptions made about reasonable consistency and gaps.
  * Tim: that's what's NAK is for
  * Jonathan: not if deliberately dropped.
      * More requirements on messy streams then assumed
      * SFUs assumed to clean up and they cant
  * Tim and Jonathan: we'll have to document that you need to deal with mess
  * Bernard: Decoders can be finicky. Example VP8. Dropping a frame, even discardable causes decoder to fail. In practice picture ID rewritten. Lot of codec specific complexities. Metadata for all codecs not possble.
  * Tim: Not able to do it yet. Three attempts.
  * Bernard: usecase assumes service provider separate from application provider. Doesn't really exist! All products have SFU and application linked. Problems for security with Javascript.
  * Tim: agree
  * Bernard: real problem is Spectre
  * Tim: assumption rewriting in SFU. Assumption is decoder doesn't know S-frame involved. Not possible.
  * Stephen: Impossible to do generically. Add to requirements codec specific restrictions on bitstring complexity. e.g. HVC no gradual decoder reflection. Need keyframes. Then may have chance.
  * Magnus: Is it really drop, or what to forward? Media streams, and assuming several streams, not just one set of packets. Underlying structure conveyed. That's part of the complexity. Need a model. What structure are we handling in an SFU context?
  * Tim: Didn't we make it work over UDP so drops work?
  * Magnus: Dropping randomly worse than selective. Random drop probability of repair or late
  * Tim: improve on random. Not perfect make it good enough.
  * Magnus: Need structure to say something lost was needed.
  * If you can't know about loss at layer, need to understand.
  * Tim: need catagorization. Could be opaque. Needs to show up
  * Magnus: How RTP works today. Sframe needs to say what you carred about.
  * PHB: why does reflector need to know stream semantics? Provided data is packaged into different streams so selection can be made. Some virtual authority saying what streams are so consumers can pick. Sufficient to solve problem.
  * Mo: Scope, sense mismatch. Started from support e2ee, but really about general transforms and packetization. Wonder about general solution or prohbit to focus on on secure media solution. Goal or nongoal about more generic.
  * Tim: Get it out fast. Insertable streams should not be a dependency
  * MT: take the goal of this to the list.
  * MT: Send emails people!

### [The big picture](https://sframe-wg.github.io/wg-materials/ietf110/big.pdf)
  * 10 min  Dr. Alex Gouaillard
  * Part of charter is big picture, carve up the territory
  * Parts media encryption, parts packetization.
  * Sadly no draft yet
  * Starting point DTLS hop by hope
  * JSEP, ICE
  * Note single stream, not until end multistream
  * JSEP/WHIP in WebRTC B
  * Mainly duplicating RTP packets, modifying headers. In addition to WebRTC have ICE, tickle, etc. 
  * E2EE where?
  * First step: additional filter between codec and RTP payload
  * Sergio Yuenn new thing: AVTCore
  * Now media server might not be able to modify RTP payload header. Need to figure out SFU information and put it.
  * So far put in RTP header extension. 1-2 years new payload frame marking. Is this enough?
  * What information where? Compatibility
  * H266 for AVI SVC codec with complexity in the SFU that needs to be handled not end to end
  * Want encryption and want SFU. Without SFU but P2P is done.
  * External key exchange with MLS
  * Sframe chartered to do encryption independent of key exchange and links
  * Depending on use case: video conference vs. one way streaming different system.
  * Need separate key management system from SFU and endpoints
  * Proposal by Richard Barns to do key exchange with MLS. Safari does additional security things. Another implemnentation with OLM by Jitsi. Webex differently, all fit diagram.
  * In web different threat model. Do not trust the javascript
  * Traditionally user agent generated
  * Now need to apply sframe transform in UA.
  * Insertable Stream API to inject encrypted content into RTP. Haven't solved key exchange. Safari native worker, not from javascript
  * Looks like things work: maybe missed a few RTCs.

### [draft-gouaillard-avtcore-codec-agn-rtp-payload](https://sframe-wg.github.io/wg-materials/ietf110/agnostic.pdf)
  * 15 min   Sergio Garcia Murillo
  * This will reappear at AVTCore
  * Hope focused on different angles
  * MT: can zoom through this, focus on the relevant bits
  * SFrame new element in RTP media chain from RFC 7656
  * Transforms encoder stream before packetizer
  * Codec specific hacks now
  * Tim: why packetize after transform?
  * Sergio: how it works! Can't explain why
  * Less overhead since data is per frame not per-packet
  * Agnostic to media transport: RTP and QUIC.
  * Bernard: Current packetizer doesn't work? Is it packetizer or SFU that forces these hacks?
  * Both!
  * VP8 and VP9 weird cases. H.264 have to parse something. Lots of media frame work to packetize.
  * Bernard: Transformer doesn't talk to packetizer. Hard req? Lots of problems. Is it shipping or what we need in arch?
  * Sergio: It's how it works today. Could do it other ways.
  * Magnus: Packetization step prior to media transform. Second one afterwards? Media encoding data? No! Multiple streams! Packetized individually with metadata to say where it belongs. Then transform and repacketize for transport. Several steps here. In WebRTC implementation, but highly relevant.
  * Sergio: not correct picture? or missing details?
  * Magnus: Scalable video codec and look at it.
  * Sergio: have slide later on for it.
  * Colin: only one possible way to implement it. Early in RTP design decision is not to build things in a codec-agnostic way. Don't try codec agnostic packetization. Because you need codec info for robustness. Can we fit this better via encryption codec aware simplify rest of design?
  * Sergio: have to specify each. Lots of work! Lots of standards to use: alphabet soup!
  * Colin: You're going to do it anyway as you realize each one is a problem.
  * Sergio: haven't seen people using it in a very codec specific way.
  * Colin: people saying in chat needed for selective forwarding.
  * Magnus: I think we're missunderstaning each other. It's not loss detection. Map SSRC to stream or layer know missing. Implement with scalable codecs maintain some of the structure, or mash to gether
  * Magnus: with Sframe not as easy. More SSRCs to see loss of layer to decide on repair.
  * Cullen: everything is packetized! Codec specific.
  * Sergio: Just chunk of bytes and metadata: frame type, layer. Not actual syntax. Need to get information that SFU needs to select
  * Cullen: Focus on the gap. Already implement not compelling. Getting right design what we're trying to do. SFU and client need to change. Both of them here.

### [MLS Integration](https://sframe-wg.github.io/wg-materials/ietf110/mls.pdf)
  * 10 min   Richard Barnes
  * SFrame needs keys, MLS provides them
  * Similar to RTP and DTLS
  * In videconference need groups. MLS does this, unlike DTLS
  * Group key exchange replaces DTLS. Use keys from MLS to Sframe.
  * Have a WG deliverable, proposal is this doc
  * 2 things: keys from MLS, put in use
  * Some negotation of other parameters via MLS.
  * Need to map group keys to per sender keys and epochs into key id field
  * Do the obvious things; use exporter, then do HKDF with sender index
  * KID is index shifted + bottom bits of the epoch
  * Certain number of bits of epoch. Implies rollover. OK!
  * Epoch guides key selection. No nonce reuse. Will have decryption failures if people don't keep up.
  * Width application specified defines how quickly have to keep up with epoch changes. Only change on joins and leaves. High churn might be an issue
  * Won't need a ton of bits. Application can manage
  * Negotiation: Key Package and welcome. offer selection
  * Implemented in SFrame repo
  * Going into Webex
  * Document seems good, some thoughts about group evolution
      * E.g. messaging to call, use some PSKs to show call and group related.
  * Adopt this?
  * MT: in last minute not a lot of opportunity. To the list!
  * MT: Other work not adopted yet. also on list

