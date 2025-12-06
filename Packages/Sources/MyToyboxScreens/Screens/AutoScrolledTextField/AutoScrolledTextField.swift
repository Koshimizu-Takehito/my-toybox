import SwiftUI

struct AutoScrolledTextFieldDemoScreen: View {
    var body: some View {
        AutoScrolledTextField()
    }
}

// MARK: - AutoScrolledTextFieldDemoScreen

/// A demonstration screen that shows how to implement a multi-line TextField
/// which automatically scrolls to the bottom when the user appends or removes text at the end.
/// This pattern is useful for chat applications, note editors, or any UI
/// where keeping the latest input visible is important, even with long text.
///
/// The implementation uses:
/// - `ScrollViewReader` to enable programmatic scrolling.
/// - A `.focused` property to automatically focus the TextField.
/// - `.onChange(of: text, initial: true)` to react to text changes and decide whether to scroll.
/// - A String extension for detecting edits at the end of the text.
struct AutoScrolledTextField: View {
    /// Holds the content of the TextField.
    /// Initialized with a long sample text.
    @State var text = String.sample

    /// Tracks whether the TextField is focused.
    /// Used to automatically show the keyboard on appear.
    @FocusState var focused: Bool

    /// A namespace for assigning a unique ID to the TextField,
    /// which is required for precise scrolling with ScrollViewReader.
    @Namespace var textFieldID

    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    // Multiline TextField with dynamic vertical sizing.
                    TextField("Sample", text: $text, axis: .vertical)
                        .focused($focused)
                        .padding()
                        .id(textFieldID)  // Required for scrolling to this field.
                }
                // When the text changes, determine if the edit was at the end.
                .onChange(of: text) { oldValue, newValue in
                    if newValue.isEndEdited(comparedTo: oldValue) {
                        withAnimation {
                            // Scrolls to the TextField, anchoring the bottom,
                            // so the latest content is always visible.
                            scrollProxy.scrollTo(textFieldID, anchor: .bottom)
                        }
                    }
                }
                // On appear, focus the TextField so the keyboard is shown immediately.
                .onAppear {
                    focused = true
                }
            }
            // Always show the vertical scroll indicator for clarity.
            .scrollIndicators(.visible, axes: .vertical)
            .navigationTitle("Scroll to new line")
        }
    }
}

// MARK: - Preview

#Preview {
    AutoScrolledTextFieldDemoScreen()
}

// MARK: - String

extension String {
    /// Returns `true` if the end of the string was edited compared to the previous value.
    ///
    /// This function checks if:
    /// - The new string starts with the old string and is longer (text was appended at the end), or
    /// - The old string starts with the new string and is longer (text was deleted from the end).
    ///
    /// This is useful for determining whether to auto-scroll to the bottom of a TextField.
    ///
    /// - Parameter other: The previous value of the string.
    /// - Returns: `true` if the edit occurred at the end.
    fileprivate func isEndEdited(comparedTo other: String) -> Bool {
        (hasPrefix(other) && count > other.count) || (other.hasPrefix(self) && other.count > count)
    }

    /// A long sample text for demonstration, representing a fictional medieval story.
    fileprivate static let sample = """
        The Chronicles of Eldermere
        In the shadow of the ancient mountains, where mist drifted endlessly through the valley and the forests whispered secrets older than kingdoms, there lay the realm of Eldermere. It was a land bound by tradition and rumor, where cobbled roads wound through villages encircled by stone walls, and the distant toll of cathedral bells measured the hours more faithfully than any clockwork device. The people of Eldermere lived by the rising and setting of the sun, and by the will of their lords.
        The tale begins in the autumn of the Year of the Serpent, a time when the leaves turned gold and crimson, and the harvest festival filled the air with the scent of roasting meats, spiced cider, and the laughter of children. In the village of Graymead, a humble farming settlement perched on the edge of Lord Harrick’s domain, sixteen-year-old Ewan son of Tomas awoke before dawn, as he did every morning. He lay for a moment in the straw-stuffed mattress, listening to the song of a lark outside the wooden shutters, and the gentle snore of his younger sister, Miriel, curled beside him for warmth.
        It was a morning like any other, except that a pale fog curled beneath the door and something in the air felt different. As he pulled on his woolen tunic and laced his boots, he remembered what his mother had said the night before: “Change is coming, Ewan. The wind smells of it.” At the time, he had smiled and said nothing, for everyone in Eldermere knew his mother was “touched by the old magic”—a blessing or a curse, depending on who was asked.
        Ewan slipped quietly from the cottage, careful not to wake the others. Outside, the world was suspended in a hush; even the animals seemed to sense the turning of the season. The fields, heavy with barley, shimmered with dew. Somewhere beyond, he could hear the slow creak of the village mill and the distant barking of a dog.
        He made his way toward the edge of the woods, intending to check the snares he’d set the previous day. As he bent to examine a trap, a sudden crack echoed through the trees—a sound that did not belong. Ewan straightened, heart thumping. In the half-light, a figure emerged from the mist. She was cloaked in blue, her face hidden by a hood, and her footsteps made no sound upon the fallen leaves.
        “Who goes there?” Ewan called, trying to make his voice steady.
        The stranger regarded him in silence for a moment before pulling back her hood. Her hair was the color of autumn wheat, and her eyes were green as moss. “I am called Alisandre,” she said softly. “I seek the healer.”
        Ewan hesitated. “My mother is a healer,” he replied, studying her closely. “But you are not from Graymead.”
        She smiled, but it was a sad, distant smile. “I have come a long way. There is little time.”
        So it was that Ewan led the stranger back to his home. His mother, upon seeing Alisandre, grew pale, then pressed her hand to her chest as if steadying herself. “You have the look of the North upon you,” she whispered. “And the burden of the old blood.”
        That day, Graymead became the stage for a story greater than any villager could have imagined. Alisandre revealed herself to be a messenger from the northern kingdom of Valtara, sent by Queen Iselda herself. War had come to the north; ancient shadows, long thought banished, were stirring. A relic of immense power—the Heartstone—had been stolen from the vaults of Valtara. Without it, the kingdom’s defenses would crumble. Alisandre’s mission was clear: find the legendary seer known only as the Starwise, rumored to dwell somewhere in the forests of Eldermere.
        Ewan’s mother, with reluctance and sorrow, admitted she knew of the Starwise. “He is a recluse, old as the hills, and not fond of visitors. But he owes me a debt.”
        Thus began the journey.
        Ewan, determined and perhaps foolish, volunteered to guide Alisandre through the wild woods, despite his mother’s protests. “You are too young for such perils,” she warned, but he would not be swayed. Miriel wept and pressed a lucky coin into his hand. The villagers watched as the pair disappeared into the trees, some whispering prayers, others omens.
        The woods of Eldermere were ancient, haunted by stories as much as by wolves and wild boars. Ewan and Alisandre walked for days, following trails marked by runes older than any written tongue. At night, they camped beneath twisted oaks and listened to the distant howling of creatures unseen. Ewan learned that Alisandre was no ordinary messenger: she bore a scar across her left hand in the shape of a serpent—a mark of the royal bloodline, and perhaps a curse.
        One evening, as the moon rose silver and full, the pair came upon a clearing. In its center stood a cottage wreathed in brambles, with smoke curling from the chimney. A black cat watched them from the windowsill. Ewan stepped forward, his heart pounding. The door creaked open before they could knock.
        An old man stood there, eyes clouded but sharp as knives. He wore a robe embroidered with stars, and his beard swept the ground. “So,” he intoned, “the Queen’s shadows have reached even here.”
        Alisandre bowed her head. “Great Starwise, we seek your counsel.”
        The Starwise listened as they told their tale. He spoke in riddles and half-truths, but in the end, he agreed to help. He drew three runes upon the hearthstone and cast a handful of ash into the fire. The flames turned blue, and the old man’s voice grew distant, as though speaking from another world.
        “North you must go, beyond the realm of men. Seek the bridge of forgotten kings, where the moon’s reflection touches the water. There you will find what you seek, but beware—the path is guarded by one who was neither living nor dead.”
        Ewan shivered. Alisandre thanked the Starwise, and the journey began anew.
        They traveled north, leaving the safety of Eldermere behind. They crossed wild rivers and bleak moors, passing through towns where rumors of war hung like storm clouds. Along the way, they gathered unlikely allies: a wandering knight named Sir Cedric, exiled for a crime he would not name; a mute stable boy with the gift of speaking to horses; and a woman called Bryndis, who wore a dagger at her belt and a map of old scars across her back.
        Each brought their own strengths and secrets. Cedric taught Ewan the basics of swordplay, though Ewan’s arms ached for days. The stable boy—whom Alisandre called Rowan—proved invaluable when the company was cornered by a band of thieves; with a whistle, he summoned a herd of wild ponies, scattering their assailants.
        Bryndis was the most mysterious of all. She spoke little, but Ewan sensed a pain in her that matched his own longing for home.
        After many trials, the company reached the bridge of forgotten kings, a crumbling span of stone arching over a black lake. At moonrise, the water glowed with an otherworldly light, revealing a stairway descending beneath the surface. There, as foretold, stood the guardian—a spectral knight in rusted armor, eyes burning with cold fire.
        “Only the worthy may pass,” intoned the guardian, raising his sword. “Speak the truth of your heart, or be lost in darkness forever.”
        One by one, the travelers spoke. Cedric confessed his deepest shame: he had failed to protect his brother in battle, and had fled in fear. Rowan revealed that he was not mute by birth, but by choice, having witnessed a horror so great that words failed him. Bryndis spoke of her lost children, taken by plague.
        At last, it was Ewan’s turn. He swallowed, searching for words. “I am afraid,” he said. “Afraid that I am too small, too weak, to change anything. But I want to try. I want to help those I love, even if it costs me everything.”
        The guardian regarded him for a long moment, then lowered his sword. “Pass, then, with my blessing.”
        They descended into the depths, where the Heartstone was hidden within a chamber of mirrors. There, Alisandre faced the final test: a vision of her own death. She faltered, but Ewan reached out and clasped her hand.
        “Courage,” he whispered.
        With trembling fingers, Alisandre claimed the Heartstone. The world shuddered as old magic awakened. The journey home was perilous; the shadows of the north pursued them, but the company’s bonds held firm.
        When at last they returned to Valtara, the Heartstone was restored, and the darkness receded. Queen Iselda welcomed them as heroes, but each bore scars—some seen, some hidden.
        Ewan returned to Graymead, forever changed. He found his mother waiting, a knowing smile upon her lips. “The wind smells different now,” she said.
        And so, the tale of Eldermere passed into legend, a story told by firelight in the years to come. The valley remained, its mysteries deep as ever, and the world turned onward, ever on the cusp of change.
        """
}
