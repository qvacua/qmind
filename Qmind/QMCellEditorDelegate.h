/**
 * Tae Won Ha — @hataewon
 *
 * http://taewon.de
 * http://qvacua.com
 *
 * See LICENSE
 */

@class QMCell;

@protocol QMCellEditorDelegate

@required
- (void)editingEndedWithString:(NSAttributedString *)newAttrStr forCell:(QMCell *)editedCell byChar:(unichar)character;
- (void)editingCancelledWithString:(NSAttributedString *)newAttrStr forCell:(QMCell *)editedCell;

@end
