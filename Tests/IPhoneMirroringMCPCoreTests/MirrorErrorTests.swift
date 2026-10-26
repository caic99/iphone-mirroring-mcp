import Testing
@testable import IPhoneMirroringMCPCore

@Suite struct MirrorErrorTests {
    @Test func stoppedInputExplainsWhy() {
        let e = MirrorError.targetOccluded(reason: "iPhone Mirroring lost focus to Notes")
        #expect(e.code == "TARGET_OCCLUDED")
        #expect(e.message == "Stopped before sending input: iPhone Mirroring lost focus to Notes. Nothing more was sent.")
    }
}
