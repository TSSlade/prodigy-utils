from typing import List

import prodigy
from prodigy.components.loaders import Audio
from prodigy.util import get_labels


def remove_base64(examples):
    """Remove base64-encoded string if "path" is preserved in example."""
    for eg in examples:
        if "audio" in eg and eg["audio"].startswith("data:") and "path" in eg:
            eg["audio"] = eg["path"]
        if "video" in eg and eg["video"].startswith("data:") and "path" in eg:
            eg["video"] = eg["path"]
    return examples


@prodigy.recipe(
    "multiclass-audio",
    dataset=("The dataset to use", "positional", None, str),
    source=("Source dir containing audio files", "positional", None, str),
    label=("Comma-separated label(s)", "option", "l", get_labels),
    )
def multiclass_audio(dataset: str,
                     label: List[str],
                     source: str):
    """ TODO: Improve docstring
    """

    def get_stream():
        # Load the directory of audio files and add options to each task
        stream = Audio(source)
        for eg in stream:
            eg["options"] = [
                {'id': 'FEM', 'text': 'Female'},
                {'id': 'MAL', 'text': 'Male'},
                {'id': 'CHI(1)', 'text': 'Child (single)'},
                {'id': 'CHI(2p)', 'text': 'Children (plural)'},
            ]
            yield eg

    with open('/Users/tsslade/Dropbox/BerkeleyMIDS/projects/w210_capstone/teacherprints/prodigy/multiclass-audio-template.html', 'r') as f:
        html_template = f.read()

    with open('./timestretcher.js') as f:
        javascript = f.read()

    blocks = [
        {'view_id': 'html', 'html_template': html_template},
        {'view_id': 'audio_manual'}
    ]

    return {
        'dataset': dataset,
        'stream': get_stream(),
        'view_id': 'blocks',
        'config': {
            'blocks': blocks,
            'javascript': javascript,
            'audio_autoplay': False,
            'audio_bar_gap': 0,
            'audio_bar_height': 10,
            'audio_bar_radius': 0,
            'audio_bar_width': 1,
            'audio_loop': False,
            'audio_max_zoom': 5000,
            'audio_rate': 1.0,
            'show_audio_cursor': True,
            'show_audio_cursor_time': True,
            'show_audio_minimap': True,
            'show_audio_timeline': True,
            'force_stream_order': True,
            'labels': ['FEM', 'MAL', 'CHI(1)', 'CHI(2p)'],
            'custom_theme': {
                'labels': {
                    'FEM': '#84E9F3',
                    'MAL': '#4E6BF3',
                    'CHI(1)': '#F2B11A',
                    'CHI(2p)': '#852215',
                }
            }
        }
    }
