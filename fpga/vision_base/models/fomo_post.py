"""Independent eight-connected FOMO grid reference; boxes are half-open in96x96."""
def components(output):
    cells = [output[i:i+4] for i in range(0, 576, 4)]
    labels = [max(range(4), key=lambda c: scores[c]) for scores in cells]
    labels = [c if c and scores[c] >= 0 else 0 for c, scores in zip(labels, cells)]
    remaining = {i for i, c in enumerate(labels) if c}
    boxes = []
    while remaining:
        first = min(remaining)
        remaining.remove(first)
        queue = [first]
        for i in queue:
            x, y = i % 12, i // 12
            for ny in range(max(0, y-1), min(12, y+2)):
                for nx in range(max(0, x-1), min(12, x+2)):
                    j = ny*12+nx
                    if j in remaining and labels[j] == labels[first]:
                        remaining.remove(j)
                        queue.append(j)
        peak = max(queue, key=lambda i: cells[i][labels[first]])
        boxes.append(dict(left=min(i % 12 for i in queue)*8, top=min(i//12 for i in queue)*8,
                          right=(max(i % 12 for i in queue)+1)*8, bottom=(max(i//12 for i in queue)+1)*8,
                          label=labels[first], confidence=cells[peak][labels[first]]+128,
                          cells=len(queue), peak_cell=peak))
    best = max(range(len(boxes)), key=lambda i: (boxes[i]['confidence'], boxes[i]['cells'])) if boxes else 0
    return boxes, best
