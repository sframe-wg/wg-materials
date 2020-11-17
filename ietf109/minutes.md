# SFrame @ IETF 109 notes

Minutes by Richard Barnes and SFrame contributors.

* Bobo: Charter review
* Youenn: In-browser use cases
    * Generic packetization
        * Emad: Interest in defining this
        * Colin Perkins: There are reasons this wasn’t done for RTP, principally resilience
        * Sergio: Want to be generic
        * Barnes: Want it both ways
        * Uberti: Could apply SFrame at the level of slices / tiles.
        * Magnus: Might want to rule some obviously bad things out of scope, e.g., shoving different codecs in one frame
    * Threat model around SFUion: is the goal knowing that media is coming from a given user? And if yes, is the SFU allowed to be malicious and part of the threat model?
        * Barnes: We shouldn’t worry about DoS
        * Emad: More about replaying things across users / inducing impersonation.  Similar to bad users.
        * EKR: We should probably drop this, really hard to do with real performance
            * With monolithic conferencing, speaker info is provided by the server anyway
        * Sergio: Don’t think we should drop this, it’s a nice feature to have; prerequisite even if not complete
        * EKR: point is not it's hard to implement, point is there's no threat model with real utility - if SFU cannot lie, who cares about signing; if it can lie (and implementation is conferencing in browser) then the party who owns the SFU also owns the UI presentation layer, so signing doesn't give additional protection
        * Emad: Suggest removing until we have a full, working solution.  Current spec is broken.
        * Barnes: let's see what other use-cases reveal; my bias is in the same direction as Emad/EKR right now
    * SFrame and Data Channel
        * Tim: would like this, many uses
        * EKR: Either way, data being sourced from JS, so ... maybe?
        * Justin: Apps like text chat are kind of similar, but input/output still JS-accessible
        * Lennox: We don't need to worry too much about the transport (e.g., maybe HLS?)
        * Mo: Same problems we have with audio/video would be worse with data channel, in terms of what the SFU needs to see to do its job

Emad: SFrame for E2EE Video Conferencing
* KID is per-user
* Signature scheme is broken right now, propose dropping for now
    * EKR: Agree that we should pull this out for now, pending use case and baked solution
    * Sergio: Signature is a good idea; fix it, don't remove it
    * Saúl: Concur with Sergio
    * Mo: Can see some benefit, but practicalities seem difficult - seems to make robustness very hard, b/c need all packets
    * Youenn: Agree with dropping it
    * Panton: Agree with dropping it, but would like to have the extra protection
    * Mohit: Does MLS help with this? 
        * RLB: No. Symmetric keys are symmetric. So SFU could spoof any stream as coming from any participant. You need signatuers for per-user authn
* Some codecs have subframe units
    * RLB: Agree with the use case.  Do you need SFrame to accommodate?  E.g., being able to delineate
    * Emad: Not clear.  Might be able to delineate in metadata, e.g., a frame header
* "IDU"s and Fragmentation
    * Magnus: People need to be clearer on terminology due to the overlap between SFRAME frames and video frames.
    * Justin: Independent Decodable Unit - "IDU"
    * Magnus: The video IDU that is protected by a single SFRAME will be larger than a single IP/UDP/RTP can carry, and thus the RTP payload level need fragmentation support for individual SFRAMES?
    * Justin: yes, fragmentation support will be needed for when IDUs exceed MTU

Sergio: Interaction between Codecs and SFrame
* Justin: transforms - ultimately we will have some transforms for existing codecs, hopefully fairly simple, and with new payload formats they will be designed to separate out their metadata from payload so no transform is needed
* Justin: we will need a h264 transform to sframe
* ... the typical concern with h264 is that frames may contain multiple payload units (i.e. NALUs), and if you encrypt each of them as an IDU you will bet
* ... *more* overhead. One potential workaround is to apply STAP-A aggregation to glue these NALUs into a single STAP-A NALU, and then it starts to look a lot 
* ... like VP8, where the first few bytes of the STAP-A are cleartext, and the rest is the encrypted payload, resulting in just a single IDU/SFRAME that 
* ... could then be fragmented in a generic fashion.
* Justin: the key question is whether the transform just decides what bits are encrypted or whether it has to map the metadata to a generic common metadata
* Stefan: SFUs commonly look at the slice header, which this has as encrypted
* ... probably what you want to do is send first four octets of NALU in the clear
* Lennox: Would be good to understand exactly what the objective is w.r.t. SFUs.
* ... could be quite a lot of work to define all this for every codec
* Magnus: Might need to do something codec-agnostic, then specialize to codecs as possible
    
RLB: Sframe and MLS (Richard Barnes, Raphael Robert)
* Crypto point of view: hard part is key management
* SFrame: defines how you encrypt a media payload
* Doesn't define: how you get the keys
* Security properties: depend on how you get the keys
* Traditional RTC Key Management has a gap - SDES, DTLS-RTP is focused on 1:1
* SFrame use-cases include N:N group use-cases - e.g. conferencing, WebRTC games, etc.
* MLS - provides continuous group authenticated key exchange with Forward Secrecy/Post Compromise Secrecy
    * Authenticated key agreement; Group (arbitrary number of participants); Continuous (join/leave triggers key refresh); FS + PCS
* SFrame needs: keys to encrypt, decrypt: lookup_key(KID) -> Key
    * Leverage MLS epochs
    * Encoding of (epoch, sender ID) tuple into KID
    * Unique uint32 for each participant in MLS Group (sender ID)
* Details: E is a truncated number of bits of the MLS epoch ID, which is 8 bytes long normally; E to be agreed upon by participants
    * Martin: I don't think that E needs to be flexible
    * Jonathan Lennox: Not for interactive use cases, I think I agree. We might want to make sure we don't have any stored-media uses cases for SFrame, though.
* RLB: Three questions for WG: 
    * 1/ Approach - generally correct?
    * 2/ MLS extn could be used to negotiate parameters (E, cipher) - should we?
    * 3/ Should we adopt a draft that defines this approach?
* Emad: Key ID derivation? - SFrame or other?
    * RLB: Sframe is the only one i've talked about. SFrame header has a Key ID and a CTR (counter). Proposal is, nonce formation works same way as in SFrame in general (via CTR), but Key ID in this proposal is derived from exported MLS secret.
* RLB: *Issue: per-sender vs. shared Key ID Space -* This scheme is designed so that Key ID space is shared across all senders, rather than per-sender; which is why you need the sender index (sender ID) in there
* EKR: everyone needs their own nonce space, right?
    * RLB: I think Emad's assumption is something at a layer outside of SFrame can indicate who the sender is, and KeyID can distinguish senders within the KeyID space
* EKR: *Issue: cipher suite negotiation -* need enough context to know what you're getting when you're getting it
* Martin: In response to Jonathan and stored media, probably have enough epochs to remain synchronized even with low-bit numbered epochs
    * RLB: Rather than stored media de-synchronization problem is why you need non-zero bits for epoch; if everyone were in synch OOB wouldn't need to signal the epoch - b/c some folks might be a couple epochs behind, need to signal it
    * Jonathan: use-case i have in mind is someone leaves a voice-mail message for someone else to listen to when they come back
* Timothy: what happens if you have the wrong epoch?
    * RLB: decryption fails
    * Timothy: no you'll get something but won't be what you think
    * RLB: no, authenticated encryption so it will fail - there are exceptionally rare cases where decryption with wrong key will succeed but with overwhelming probability will fail
    * RLB: so you can recover from epoch wraps
    * Martin: but we try to avoid those

Draft adoptions
* Martin: *Show of Hands-* How many people have read the SFrame draft?
    * Raised: 16 | Not Raised: 4 | Participants: 44
* Martin: *Show of Hands-* How many people have read the SFrame-MLS draft?
    * Raised: 4 | Not Raised: 18 | Participants: 44
* Martin: *Show of Hands-* Should we adopt draft-omara-sframe?
    * Raised: 14 | Not Raised: 3 | Participants: 43
    * Colin: i'm assuming we will eventually adopt this, i said no b/c i want to better understand RTP and packetization, get a handle on that first
* Martin: we'll send roudn an email re: adoption, see if list agrees w/ vague indications that there's support for adopting this one; will be good to hear arguments for delaying as well if folks want to make those

Encryption for content protection in streaming - Dr Alex
* Video conference vs. Content streaming are two different trust-models
* SFrame separates media encryption from key management etc. - could be useful for broadcasting infra for real-time content (rather than video on demand, which is well-served already)
* Not sure we've served 1:N w/ very large N (vs. 1:1 or N:N with manageably-sized N)
* Timothy: This is interesting - also question around plausible deniability for service provider. For me and my use-case N is probably 10, much smaller.
* Dr Alex: when N is < 1000 it's basically video-conferencing mode; when N is > 50k or more then you need new solutions
* Dr Alex: content generator may want to control rights, e.g. via a pay-per-access token, moving that access control to the generator rather than distribution platform
    * But you'd still want the distribution infra to be able to do rate matching and all that stuff
* Loren McIntyre: there's a project doing p2p video-conferencing, can swap between direct peering and using an SFU - just wanted to make this WG aware of the use-case: https://github.com/meething/meething
